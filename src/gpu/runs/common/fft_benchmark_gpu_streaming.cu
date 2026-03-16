#include <ctype.h>
#include <cuda_runtime.h>
#include <cufft.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LIST 64

static int env_int(const char *name, int fallback, int min_v, int max_v)
{
    const char *s = getenv(name);
    if (!s || !*s) return fallback;

    char *end = NULL;
    long v = strtol(s, &end, 10);
    if (end == s || *end != '\0') return fallback;
    if (v < min_v || v > max_v) return fallback;
    return (int)v;
}

static double env_double(const char *name, double fallback, double min_v, double max_v)
{
    const char *s = getenv(name);
    if (!s || !*s) return fallback;

    char *end = NULL;
    double v = strtod(s, &end);
    if (end == s || *end != '\0') return fallback;
    if (v < min_v || v > max_v) return fallback;
    return v;
}

static char *trim(char *s)
{
    while (*s && isspace((unsigned char)*s)) s++;
    if (!*s) return s;

    char *end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) {
        *end = '\0';
        end--;
    }
    return s;
}

static int parse_int_list(const char *raw, int *out, int max_count, int min_v, int max_v)
{
    if (!raw || !*raw || max_count <= 0) return 0;

    size_t len = strlen(raw);
    char *buf = (char *)malloc(len + 1);
    if (!buf) return 0;
    memcpy(buf, raw, len + 1);

    int count = 0;
    char *save = NULL;
    char *tok = strtok_r(buf, ",", &save);
    while (tok && count < max_count) {
        char *t = trim(tok);
        if (*t) {
            char *end = NULL;
            long v = strtol(t, &end, 10);
            if (end != t && *end == '\0' && v >= min_v && v <= max_v) {
                out[count++] = (int)v;
            }
        }
        tok = strtok_r(NULL, ",", &save);
    }

    free(buf);
    return count;
}

static int load_int_list(const char *env_name, const char *fallback,
                         int *out, int max_count, int min_v, int max_v)
{
    const char *s = getenv(env_name);
    if (!s || !*s) s = fallback;
    return parse_int_list(s, out, max_count, min_v, max_v);
}

static void print_list(const char *name, const int *arr, int n)
{
    printf("%s: ", name);
    for (int i = 0; i < n; i++) {
        printf("%d", arr[i]);
        if (i + 1 < n) printf(",");
    }
    printf("\n");
}

static void section(const char *title)
{
    printf("\n====================================================================\n");
    printf("%s\n", title);
    printf("====================================================================\n");
}

static const char *cufft_status_string(cufftResult r)
{
    switch (r) {
    case CUFFT_SUCCESS: return "CUFFT_SUCCESS";
    case CUFFT_INVALID_PLAN: return "CUFFT_INVALID_PLAN";
    case CUFFT_ALLOC_FAILED: return "CUFFT_ALLOC_FAILED";
    case CUFFT_INVALID_TYPE: return "CUFFT_INVALID_TYPE";
    case CUFFT_INVALID_VALUE: return "CUFFT_INVALID_VALUE";
    case CUFFT_INTERNAL_ERROR: return "CUFFT_INTERNAL_ERROR";
    case CUFFT_EXEC_FAILED: return "CUFFT_EXEC_FAILED";
    case CUFFT_SETUP_FAILED: return "CUFFT_SETUP_FAILED";
    case CUFFT_INVALID_SIZE: return "CUFFT_INVALID_SIZE";
    case CUFFT_UNALIGNED_DATA: return "CUFFT_UNALIGNED_DATA";
    case CUFFT_INCOMPLETE_PARAMETER_LIST: return "CUFFT_INCOMPLETE_PARAMETER_LIST";
    case CUFFT_INVALID_DEVICE: return "CUFFT_INVALID_DEVICE";
    case CUFFT_PARSE_ERROR: return "CUFFT_PARSE_ERROR";
    case CUFFT_NO_WORKSPACE: return "CUFFT_NO_WORKSPACE";
    case CUFFT_NOT_IMPLEMENTED: return "CUFFT_NOT_IMPLEMENTED";
    case CUFFT_LICENSE_ERROR: return "CUFFT_LICENSE_ERROR";
    case CUFFT_NOT_SUPPORTED: return "CUFFT_NOT_SUPPORTED";
    default: return "CUFFT_UNKNOWN_ERROR";
    }
}

static uint32_t lcg32_next(uint32_t *state)
{
    *state = (*state * 1664525u) + 1013904223u;
    return *state;
}

static float lcg32_unit_float(uint32_t *state)
{
    uint32_t v = lcg32_next(state);
    return (float)(v & 0x00FFFFFFu) / (float)0x01000000u;
}

static void fill_host_tensor(cufftComplex *data, size_t total, uint32_t seed)
{
    uint32_t state = seed ? seed : 1u;
    for (size_t i = 0; i < total; i++) {
        data[i].x = lcg32_unit_float(&state);
        data[i].y = lcg32_unit_float(&state);
    }
}

static void emit_skip(const char *profile_id,
                      const char *workload,
                      const char *case_id,
                      int n,
                      int howmany,
                      int threads_field,
                      double mem_mb,
                      int stream_slots,
                      double work_area_mb,
                      const char *reason)
{
    printf("[skip] %-16s | Len:%7d | Batch:%6d | Thr:%2d | Slots:%7d | "
           "Mem:%9.2f MB | Work:%8.2f MB | Reason:%s\n",
           case_id,
           n,
           howmany,
           threads_field,
           stream_slots,
           mem_mb,
           work_area_mb,
           reason);
    printf("SKIP|%s|%s|%s|%d|%d|%d|%d|%d|%.2f|%s|%d|%.2f\n",
           profile_id,
           workload,
           case_id,
           n,
           1,
           1,
           howmany,
           threads_field,
           mem_mb,
           reason,
           stream_slots,
           work_area_mb);
    fflush(stdout);
}

static int prepare_plan(int n, int howmany, cufftHandle *plan_out, size_t *work_bytes_out)
{
    cufftHandle plan = 0;
    long long dims[1] = {(long long)n};
    long long inembed[1] = {(long long)n};
    long long onembed[1] = {(long long)n};
    size_t work_bytes = 0;

    cufftResult cr = cufftCreate(&plan);
    if (cr != CUFFT_SUCCESS) {
        fprintf(stderr, "ERROR: cufftCreate failed: %s\n", cufft_status_string(cr));
        return 0;
    }

    cr = cufftSetAutoAllocation(plan, 0);
    if (cr != CUFFT_SUCCESS) {
        fprintf(stderr, "ERROR: cufftSetAutoAllocation failed: %s\n", cufft_status_string(cr));
        cufftDestroy(plan);
        return 0;
    }

    cr = cufftMakePlanMany64(plan,
                             1,
                             dims,
                             inembed,
                             1,
                             (long long)n,
                             onembed,
                             1,
                             (long long)n,
                             CUFFT_C2C,
                             (long long)howmany,
                             &work_bytes);
    if (cr != CUFFT_SUCCESS) {
        fprintf(stderr, "ERROR: cufftMakePlanMany64 failed: %s\n", cufft_status_string(cr));
        cufftDestroy(plan);
        return 0;
    }

    *plan_out = plan;
    *work_bytes_out = work_bytes;
    return 1;
}

static int validate_roundtrip(const char *profile_id,
                              const char *workload,
                              const char *case_id,
                              int n,
                              int howmany,
                              int threads_field,
                              cufftHandle plan,
                              cufftComplex *d_in_slot0,
                              cufftComplex *d_out_slot0,
                              cufftComplex *d_orig,
                              cufftComplex *h_ref,
                              cufftComplex *h_chk,
                              size_t tensor_bytes,
                              double tol)
{
    cufftResult cr = cufftExecC2C(plan, d_in_slot0, d_out_slot0, CUFFT_FORWARD);
    if (cr != CUFFT_SUCCESS) {
        fprintf(stderr, "ERROR: validation forward failed for %s: %s\n", case_id, cufft_status_string(cr));
        return -1;
    }
    cr = cufftExecC2C(plan, d_out_slot0, d_in_slot0, CUFFT_INVERSE);
    if (cr != CUFFT_SUCCESS) {
        fprintf(stderr, "ERROR: validation backward failed for %s: %s\n", case_id, cufft_status_string(cr));
        return -1;
    }
    cudaError_t ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: validation synchronize failed for %s: %s\n", case_id, cudaGetErrorString(ce));
        return -1;
    }

    ce = cudaMemcpy(h_chk, d_in_slot0, tensor_bytes, cudaMemcpyDeviceToHost);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: validation copy-back failed for %s: %s\n", case_id, cudaGetErrorString(ce));
        return -1;
    }

    size_t total = (size_t)n * (size_t)howmany;
    double inv_n = 1.0 / (double)n;
    double sum_ref2 = 0.0;
    double sum_err2 = 0.0;
    double max_abs = 0.0;
    for (size_t i = 0; i < total; i++) {
        double rr = (double)h_ref[i].x;
        double ri = (double)h_ref[i].y;
        double xr = (double)h_chk[i].x * inv_n;
        double xi = (double)h_chk[i].y * inv_n;
        double dr = xr - rr;
        double di = xi - ri;
        double err_abs = sqrt(dr * dr + di * di);
        if (err_abs > max_abs) max_abs = err_abs;
        sum_ref2 += rr * rr + ri * ri;
        sum_err2 += dr * dr + di * di;
    }

    double denom = sum_ref2 > 1.0e-30 ? sum_ref2 : 1.0e-30;
    double rel_rms = sqrt(sum_err2 / denom);
    int pass = (rel_rms <= tol) || (max_abs <= tol);

    printf("CHECK|%s|%s|%s|%d|%d|%d|%d|%d|%.8e|%.8e|%.8e|%s\n",
           profile_id,
           workload,
           case_id,
           n,
           1,
           1,
           howmany,
           threads_field,
           rel_rms,
           max_abs,
           tol,
           pass ? "PASS" : "FAIL");
    fflush(stdout);

    ce = cudaMemcpy(d_in_slot0, d_orig, tensor_bytes, cudaMemcpyDeviceToDevice);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: validation restore input failed for %s: %s\n", case_id, cudaGetErrorString(ce));
        return -1;
    }
    ce = cudaMemset(d_out_slot0, 0, tensor_bytes);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: validation clear output failed for %s: %s\n", case_id, cudaGetErrorString(ce));
        return -1;
    }
    ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: validation restore synchronize failed for %s: %s\n", case_id, cudaGetErrorString(ce));
        return -1;
    }

    return pass ? 1 : 0;
}

static int timed_forward_adaptive(cufftHandle plan,
                                  cufftComplex *d_in_pool,
                                  cufftComplex *d_out_pool,
                                  size_t total,
                                  int stream_slots,
                                  int warmup_runs,
                                  int nruns,
                                  double min_total_ms,
                                  int max_adapt_iters,
                                  double *avg_ms_out,
                                  int *timed_iters_out)
{
    int timed_iters = nruns > 0 ? nruns : 1;
    if (timed_iters > max_adapt_iters) timed_iters = max_adapt_iters;

    for (int i = 0; i < warmup_runs; i++) {
        int slot = stream_slots > 1 ? (i % stream_slots) : 0;
        cufftComplex *d_in = d_in_pool + ((size_t)slot * total);
        cufftComplex *d_out = d_out_pool + ((size_t)slot * total);
        cufftResult cr = cufftExecC2C(plan, d_in, d_out, CUFFT_FORWARD);
        if (cr != CUFFT_SUCCESS) {
            fprintf(stderr, "ERROR: warmup forward failed: %s\n", cufft_status_string(cr));
            return 0;
        }
    }

    cudaError_t ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: warmup forward synchronize failed: %s\n", cudaGetErrorString(ce));
        return 0;
    }

    cudaEvent_t ev_start = NULL;
    cudaEvent_t ev_end = NULL;
    ce = cudaEventCreate(&ev_start);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaEventCreate(start) failed: %s\n", cudaGetErrorString(ce));
        return 0;
    }
    ce = cudaEventCreate(&ev_end);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaEventCreate(end) failed: %s\n", cudaGetErrorString(ce));
        cudaEventDestroy(ev_start);
        return 0;
    }

    float elapsed_ms = 0.0f;
    for (;;) {
        ce = cudaEventRecord(ev_start);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventRecord(start) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }

        for (int i = 0; i < timed_iters; i++) {
            int slot = stream_slots > 1 ? (i % stream_slots) : 0;
            cufftComplex *d_in = d_in_pool + ((size_t)slot * total);
            cufftComplex *d_out = d_out_pool + ((size_t)slot * total);
            cufftResult cr = cufftExecC2C(plan, d_in, d_out, CUFFT_FORWARD);
            if (cr != CUFFT_SUCCESS) {
                fprintf(stderr, "ERROR: timed forward failed: %s\n", cufft_status_string(cr));
                cudaEventDestroy(ev_start);
                cudaEventDestroy(ev_end);
                return 0;
            }
        }

        ce = cudaEventRecord(ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventRecord(end) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }
        ce = cudaEventSynchronize(ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventSynchronize(end) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }
        ce = cudaEventElapsedTime(&elapsed_ms, ev_start, ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventElapsedTime failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }

        if ((double)elapsed_ms >= min_total_ms || timed_iters >= max_adapt_iters) break;

        double safe_elapsed = elapsed_ms > 1.0e-3f ? (double)elapsed_ms : 1.0e-3;
        long long candidate = (long long)ceil((double)timed_iters * (min_total_ms / safe_elapsed));
        if (candidate <= timed_iters) candidate = (long long)timed_iters * 2LL;
        if (candidate > (long long)max_adapt_iters) candidate = (long long)max_adapt_iters;
        timed_iters = (int)candidate;
    }

    cudaEventDestroy(ev_start);
    cudaEventDestroy(ev_end);

    if (elapsed_ms <= 0.0f) elapsed_ms = 1.0e-6f;
    *avg_ms_out = (double)elapsed_ms / (double)timed_iters;
    *timed_iters_out = timed_iters;
    return 1;
}

static int timed_backward_adaptive(cufftHandle plan,
                                   cufftComplex *d_out_pool,
                                   cufftComplex *d_in_pool,
                                   size_t total,
                                   int stream_slots,
                                   int warmup_runs,
                                   int nruns,
                                   double min_total_ms,
                                   int max_adapt_iters,
                                   double *avg_ms_out,
                                   int *timed_iters_out)
{
    int timed_iters = nruns > 0 ? nruns : 1;
    if (timed_iters > max_adapt_iters) timed_iters = max_adapt_iters;

    for (int i = 0; i < warmup_runs; i++) {
        int slot = stream_slots > 1 ? (i % stream_slots) : 0;
        cufftComplex *d_out = d_out_pool + ((size_t)slot * total);
        cufftComplex *d_in = d_in_pool + ((size_t)slot * total);
        cufftResult cr = cufftExecC2C(plan, d_out, d_in, CUFFT_INVERSE);
        if (cr != CUFFT_SUCCESS) {
            fprintf(stderr, "ERROR: warmup backward failed: %s\n", cufft_status_string(cr));
            return 0;
        }
    }

    cudaError_t ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: warmup backward synchronize failed: %s\n", cudaGetErrorString(ce));
        return 0;
    }

    cudaEvent_t ev_start = NULL;
    cudaEvent_t ev_end = NULL;
    ce = cudaEventCreate(&ev_start);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaEventCreate(start,bwd) failed: %s\n", cudaGetErrorString(ce));
        return 0;
    }
    ce = cudaEventCreate(&ev_end);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaEventCreate(end,bwd) failed: %s\n", cudaGetErrorString(ce));
        cudaEventDestroy(ev_start);
        return 0;
    }

    float elapsed_ms = 0.0f;
    for (;;) {
        ce = cudaEventRecord(ev_start);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventRecord(start,bwd) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }

        for (int i = 0; i < timed_iters; i++) {
            int slot = stream_slots > 1 ? (i % stream_slots) : 0;
            cufftComplex *d_out = d_out_pool + ((size_t)slot * total);
            cufftComplex *d_in = d_in_pool + ((size_t)slot * total);
            cufftResult cr = cufftExecC2C(plan, d_out, d_in, CUFFT_INVERSE);
            if (cr != CUFFT_SUCCESS) {
                fprintf(stderr, "ERROR: timed backward failed: %s\n", cufft_status_string(cr));
                cudaEventDestroy(ev_start);
                cudaEventDestroy(ev_end);
                return 0;
            }
        }

        ce = cudaEventRecord(ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventRecord(end,bwd) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }
        ce = cudaEventSynchronize(ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventSynchronize(end,bwd) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }
        ce = cudaEventElapsedTime(&elapsed_ms, ev_start, ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventElapsedTime(bwd) failed: %s\n", cudaGetErrorString(ce));
            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
            return 0;
        }

        if ((double)elapsed_ms >= min_total_ms || timed_iters >= max_adapt_iters) break;

        double safe_elapsed = elapsed_ms > 1.0e-3f ? (double)elapsed_ms : 1.0e-3;
        long long candidate = (long long)ceil((double)timed_iters * (min_total_ms / safe_elapsed));
        if (candidate <= timed_iters) candidate = (long long)timed_iters * 2LL;
        if (candidate > (long long)max_adapt_iters) candidate = (long long)max_adapt_iters;
        timed_iters = (int)candidate;
    }

    cudaEventDestroy(ev_start);
    cudaEventDestroy(ev_end);

    if (elapsed_ms <= 0.0f) elapsed_ms = 1.0e-6f;
    *avg_ms_out = (double)elapsed_ms / (double)timed_iters;
    *timed_iters_out = timed_iters;
    return 1;
}

static void run_benchmark(const char *profile_id,
                          const char *workload,
                          const char *case_id,
                          int n,
                          int howmany,
                          int threads_field,
                          int warmup_runs,
                          int nruns,
                          double max_mem_mb,
                          double min_total_ms,
                          int max_adapt_iters,
                          int do_validate,
                          double validate_tol,
                          int validate_strict,
                          int stream_mode,
                          double stream_target_mb,
                          int stream_min_slots,
                          int stream_max_slots)
{
    size_t total = (size_t)n * (size_t)howmany;
    size_t tensor_bytes = total * sizeof(cufftComplex);
    size_t slot_bytes = tensor_bytes * 2U;
    size_t orig_bytes = tensor_bytes;
    double single_slot_mb = (double)slot_bytes / (1024.0 * 1024.0);

    int stream_slots = 1;
    if (stream_mode) {
        double target_bytes_d = stream_target_mb * 1024.0 * 1024.0;
        size_t target_bytes = target_bytes_d > 0.0 ? (size_t)target_bytes_d : 1U;
        stream_slots = (int)((target_bytes + slot_bytes - 1U) / slot_bytes);
        if (stream_slots < stream_min_slots) stream_slots = stream_min_slots;
        if (stream_slots > stream_max_slots) stream_slots = stream_max_slots;
    }
    if (stream_slots < 1) stream_slots = 1;

    cufftHandle plan = 0;
    size_t work_bytes = 0;
    if (!prepare_plan(n, howmany, &plan, &work_bytes)) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  single_slot_mb,
                  stream_slots,
                  (double)work_bytes / (1024.0 * 1024.0),
                  "plan_setup_failed");
        return;
    }
    cufftSetStream(plan, 0);

    if (max_mem_mb > 0.0) {
        size_t max_bytes = (size_t)(max_mem_mb * 1024.0 * 1024.0);
        size_t base_bytes = orig_bytes + work_bytes;
        if (max_bytes <= base_bytes + slot_bytes) {
            emit_skip(profile_id,
                      workload,
                      case_id,
                      n,
                      howmany,
                      threads_field,
                      (double)(base_bytes + slot_bytes) / (1024.0 * 1024.0),
                      stream_slots,
                      (double)work_bytes / (1024.0 * 1024.0),
                      "memory_limit");
            cufftDestroy(plan);
            return;
        }

        size_t max_slots_by_mem = (max_bytes - base_bytes) / slot_bytes;
        if (max_slots_by_mem == 0) max_slots_by_mem = 1;
        if ((size_t)stream_slots > max_slots_by_mem) stream_slots = (int)max_slots_by_mem;
    }

    size_t pool_bytes = (size_t)stream_slots * tensor_bytes;
    double working_mem_mb =
        (double)(orig_bytes + work_bytes + ((size_t)stream_slots * slot_bytes)) / (1024.0 * 1024.0);
    double work_area_mb = (double)work_bytes / (1024.0 * 1024.0);

    void *d_work = NULL;
    if (work_bytes > 0) {
        cudaError_t ce = cudaMalloc(&d_work, work_bytes);
        if (ce != cudaSuccess) {
            emit_skip(profile_id,
                      workload,
                      case_id,
                      n,
                      howmany,
                      threads_field,
                      working_mem_mb,
                      stream_slots,
                      work_area_mb,
                      "cuda_malloc_work_failed");
            cufftDestroy(plan);
            return;
        }
        cufftResult cr = cufftSetWorkArea(plan, d_work);
        if (cr != CUFFT_SUCCESS) {
            emit_skip(profile_id,
                      workload,
                      case_id,
                      n,
                      howmany,
                      threads_field,
                      working_mem_mb,
                      stream_slots,
                      work_area_mb,
                      "cufft_set_workarea_failed");
            cudaFree(d_work);
            cufftDestroy(plan);
            return;
        }
    }

    cufftComplex *d_in_pool = NULL;
    cufftComplex *d_out_pool = NULL;
    cufftComplex *d_orig = NULL;
    cufftComplex *h_stage = NULL;
    cufftComplex *h_ref = NULL;
    cufftComplex *h_chk = NULL;

    cudaError_t ce = cudaMalloc((void **)&d_in_pool, pool_bytes);
    if (ce != cudaSuccess) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "cuda_malloc_in_failed");
        if (d_work) cudaFree(d_work);
        cufftDestroy(plan);
        return;
    }
    ce = cudaMalloc((void **)&d_out_pool, pool_bytes);
    if (ce != cudaSuccess) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "cuda_malloc_out_failed");
        cudaFree(d_in_pool);
        if (d_work) cudaFree(d_work);
        cufftDestroy(plan);
        return;
    }
    ce = cudaMalloc((void **)&d_orig, orig_bytes);
    if (ce != cudaSuccess) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "cuda_malloc_orig_failed");
        cudaFree(d_in_pool);
        cudaFree(d_out_pool);
        if (d_work) cudaFree(d_work);
        cufftDestroy(plan);
        return;
    }

    h_stage = (cufftComplex *)malloc(tensor_bytes);
    if (do_validate) {
        h_ref = (cufftComplex *)malloc(tensor_bytes);
        h_chk = (cufftComplex *)malloc(tensor_bytes);
    }
    if (!h_stage || (do_validate && (!h_ref || !h_chk))) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "host_buffer_alloc_failed");
        free(h_stage);
        free(h_ref);
        free(h_chk);
        cudaFree(d_in_pool);
        cudaFree(d_out_pool);
        cudaFree(d_orig);
        if (d_work) cudaFree(d_work);
        cufftDestroy(plan);
        return;
    }

    ce = cudaMemset(d_out_pool, 0, pool_bytes);
    if (ce != cudaSuccess) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "cuda_memset_out_failed");
        free(h_stage);
        free(h_ref);
        free(h_chk);
        cudaFree(d_in_pool);
        cudaFree(d_out_pool);
        cudaFree(d_orig);
        if (d_work) cudaFree(d_work);
        cufftDestroy(plan);
        return;
    }

    for (int slot = 0; slot < stream_slots; slot++) {
        uint32_t seed = 42u + (uint32_t)(slot * 10007u) + (uint32_t)(n * 7 + howmany);
        fill_host_tensor(h_stage, total, seed);
        cufftComplex *d_slot = d_in_pool + ((size_t)slot * total);
        ce = cudaMemcpy(d_slot, h_stage, tensor_bytes, cudaMemcpyHostToDevice);
        if (ce != cudaSuccess) {
            emit_skip(profile_id,
                      workload,
                      case_id,
                      n,
                      howmany,
                      threads_field,
                      working_mem_mb,
                      stream_slots,
                      work_area_mb,
                      "cuda_memcpy_init_failed");
            free(h_stage);
            free(h_ref);
            free(h_chk);
            cudaFree(d_in_pool);
            cudaFree(d_out_pool);
            cudaFree(d_orig);
            if (d_work) cudaFree(d_work);
            cufftDestroy(plan);
            return;
        }
        if (slot == 0) {
            if (do_validate) memcpy(h_ref, h_stage, tensor_bytes);
            ce = cudaMemcpy(d_orig, h_stage, tensor_bytes, cudaMemcpyHostToDevice);
            if (ce != cudaSuccess) {
                emit_skip(profile_id,
                          workload,
                          case_id,
                          n,
                          howmany,
                          threads_field,
                          working_mem_mb,
                          stream_slots,
                          work_area_mb,
                          "cuda_memcpy_orig_failed");
                free(h_stage);
                free(h_ref);
                free(h_chk);
                cudaFree(d_in_pool);
                cudaFree(d_out_pool);
                cudaFree(d_orig);
                if (d_work) cudaFree(d_work);
                cufftDestroy(plan);
                return;
            }
        }
    }

    ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "cuda_sync_after_init_failed");
        free(h_stage);
        free(h_ref);
        free(h_chk);
        cudaFree(d_in_pool);
        cudaFree(d_out_pool);
        cudaFree(d_orig);
        if (d_work) cudaFree(d_work);
        cufftDestroy(plan);
        return;
    }

    if (do_validate) {
        int ok = validate_roundtrip(profile_id,
                                    workload,
                                    case_id,
                                    n,
                                    howmany,
                                    threads_field,
                                    plan,
                                    d_in_pool,
                                    d_out_pool,
                                    d_orig,
                                    h_ref,
                                    h_chk,
                                    tensor_bytes,
                                    validate_tol);
        if (ok < 0) {
            free(h_stage);
            free(h_ref);
            free(h_chk);
            cudaFree(d_in_pool);
            cudaFree(d_out_pool);
            cudaFree(d_orig);
            if (d_work) cudaFree(d_work);
            cufftDestroy(plan);
            return;
        }
        if (ok == 0 && validate_strict) {
            fprintf(stderr, "ERROR: validation failed (strict mode) for %s\n", case_id);
            free(h_stage);
            free(h_ref);
            free(h_chk);
            cudaFree(d_in_pool);
            cudaFree(d_out_pool);
            cudaFree(d_orig);
            if (d_work) cudaFree(d_work);
            cufftDestroy(plan);
            return;
        }
    }

    double fwd_ms = 0.0;
    double bwd_ms = 0.0;
    int fwd_iters = 0;
    int bwd_iters = 0;
    int ok = timed_forward_adaptive(plan,
                                    d_in_pool,
                                    d_out_pool,
                                    total,
                                    stream_slots,
                                    warmup_runs,
                                    nruns,
                                    min_total_ms,
                                    max_adapt_iters,
                                    &fwd_ms,
                                    &fwd_iters);
    if (ok) {
        ok = timed_backward_adaptive(plan,
                                     d_out_pool,
                                     d_in_pool,
                                     total,
                                     stream_slots,
                                     warmup_runs,
                                     nruns,
                                     min_total_ms,
                                     max_adapt_iters,
                                     &bwd_ms,
                                     &bwd_iters);
    }

    if (ok && fwd_ms > 0.0 && bwd_ms > 0.0) {
        double flops = 5.0 * (double)n * log2((double)n) * (double)howmany;
        double fwd_gflops = flops / (fwd_ms * 1.0e6);
        double bwd_gflops = flops / (bwd_ms * 1.0e6);
        printf("[run ] %-16s | Len:%7d | Batch:%6d | Thr:%2d | "
               "Fwd:%10.4f ms %8.2f GF/s (iters:%d) | "
               "Bwd:%10.4f ms %8.2f GF/s (iters:%d) | "
               "Slots:%7d | Mem:%9.2f MB | Work:%8.2f MB\n",
               case_id,
               n,
               howmany,
               threads_field,
               fwd_ms,
               fwd_gflops,
               fwd_iters,
               bwd_ms,
               bwd_gflops,
               bwd_iters,
               stream_slots,
               working_mem_mb,
               work_area_mb);
        printf("RESULT|%s|%s|%s|%d|%d|%d|%d|%d|%.6f|%.6f|%.6f|%.6f|%.2f|%d|%.2f\n",
               profile_id,
               workload,
               case_id,
               n,
               1,
               1,
               howmany,
               threads_field,
               fwd_ms,
               fwd_gflops,
               bwd_ms,
               bwd_gflops,
               working_mem_mb,
               stream_slots,
               work_area_mb);
    } else {
        emit_skip(profile_id,
                  workload,
                  case_id,
                  n,
                  howmany,
                  threads_field,
                  working_mem_mb,
                  stream_slots,
                  work_area_mb,
                  "execution_failed");
    }
    fflush(stdout);

    free(h_stage);
    free(h_ref);
    free(h_chk);
    cudaFree(d_in_pool);
    cudaFree(d_out_pool);
    cudaFree(d_orig);
    if (d_work) cudaFree(d_work);
    cufftDestroy(plan);
}

static void run_throughput(const char *profile_id,
                           int threads_field,
                           int warmup_runs,
                           int nruns,
                           double max_mem_mb,
                           double min_total_ms,
                           int max_adapt_iters,
                           int do_validate,
                           double validate_tol,
                           int validate_strict,
                           int stream_mode,
                           double stream_target_mb,
                           int stream_min_slots,
                           int stream_max_slots,
                           const int *lengths,
                           int n_lengths,
                           const int *batches,
                           int n_batches)
{
    section("WORKLOAD: throughput (length x batch at fixed CUDA profile)");
    printf("threads_field=%d\n", threads_field);

    for (int i = 0; i < n_lengths; i++) {
        for (int j = 0; j < n_batches; j++) {
            char case_id[64];
            snprintf(case_id, sizeof(case_id), "n%d_b%d", lengths[i], batches[j]);
            run_benchmark(profile_id,
                          "throughput",
                          case_id,
                          lengths[i],
                          batches[j],
                          threads_field,
                          warmup_runs,
                          nruns,
                          max_mem_mb,
                          min_total_ms,
                          max_adapt_iters,
                          do_validate,
                          validate_tol,
                          validate_strict,
                          stream_mode,
                          stream_target_mb,
                          stream_min_slots,
                          stream_max_slots);
        }
    }
}

int main(void)
{
    int nruns = env_int("BENCH_NRUNS", 20, 1, 100000000);
    int warmup_runs = env_int("BENCH_WARMUP", 5, 0, 100000000);
    double max_mem_mb = env_double("BENCH_MAX_MEM_MB", 8192.0, 0.0, 1048576.0);
    double min_total_ms = env_double("BENCH_MIN_TOTAL_MS", 50.0, 1.0, 600000.0);
    int max_adapt_iters = env_int("BENCH_MAX_ADAPT_ITERS", 100000000, 1, 1000000000);
    int do_validate = env_int("BENCH_VALIDATE", 1, 0, 1);
    double validate_tol = env_double("BENCH_VALIDATE_TOL", 1e-4, 1e-12, 1.0);
    int validate_strict = env_int("BENCH_VALIDATE_STRICT", 1, 0, 1);
    int stream_mode = env_int("BENCH_STREAM_MODE", 0, 0, 1);
    double stream_target_mb = env_double("BENCH_STREAM_TARGET_MB", 128.0, 0.0, 1048576.0);
    int stream_min_slots = env_int("BENCH_STREAM_MIN_SLOTS", 2, 1, 1 << 20);
    int stream_max_slots = env_int("BENCH_STREAM_MAX_SLOTS", 262144, 1, 1 << 24);
    int threads_field = env_int("BENCH_THREADS_FIELD", 1, 1, 65535);
    int device_index = env_int("BENCH_DEVICE_INDEX", 0, 0, 127);

    const char *profile_id = getenv("BENCH_PROFILE");
    if (!profile_id || !*profile_id) profile_id = "manual_gpu";
    const char *profile_desc = getenv("BENCH_PROFILE_DESC");
    if (!profile_desc || !*profile_desc) profile_desc = "manual cuFFT run";
    const char *workload = getenv("BENCH_WORKLOAD");
    if (!workload || !*workload) workload = "throughput";

    int lengths[MAX_LIST];
    int batches[MAX_LIST];
    int n_lengths = load_int_list("BENCH_LENGTHS",
                                  "2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536",
                                  lengths,
                                  MAX_LIST,
                                  1,
                                  1 << 26);
    int n_batches = load_int_list("BENCH_BATCHES",
                                  "1,10,16,150,256,1024",
                                  batches,
                                  MAX_LIST,
                                  1,
                                  1 << 20);

    if (n_lengths <= 0) {
        lengths[0] = 1024;
        lengths[1] = 4096;
        lengths[2] = 16384;
        n_lengths = 3;
    }
    if (n_batches <= 0) {
        batches[0] = 1;
        batches[1] = 10;
        batches[2] = 16;
        batches[3] = 150;
        batches[4] = 256;
        batches[5] = 1024;
        n_batches = 6;
    }

    int device_count = 0;
    cudaError_t ce = cudaGetDeviceCount(&device_count);
    if (ce != cudaSuccess || device_count <= 0) {
        fprintf(stderr, "ERROR: no CUDA devices available: %s\n", cudaGetErrorString(ce));
        return 1;
    }
    if (device_index >= device_count) {
        fprintf(stderr, "ERROR: BENCH_DEVICE_INDEX=%d but only %d device(s) available\n",
                device_index,
                device_count);
        return 1;
    }
    ce = cudaSetDevice(device_index);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaSetDevice(%d) failed: %s\n", device_index, cudaGetErrorString(ce));
        return 1;
    }

    cudaDeviceProp prop;
    ce = cudaGetDeviceProperties(&prop, device_index);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaGetDeviceProperties failed: %s\n", cudaGetErrorString(ce));
        return 1;
    }

    printf("\n############################################################\n");
    printf("# FFT BENCHMARK (cuFFT, 1D, single precision)              #\n");
    printf("############################################################\n");
    printf("profile_id       : %s\n", profile_id);
    printf("profile_desc     : %s\n", profile_desc);
    printf("workload         : %s\n", workload);
    printf("device_index     : %d\n", device_index);
    printf("timed runs       : %d\n", nruns);
    printf("warmup runs      : %d\n", warmup_runs);
    printf("min total ms     : %.1f\n", min_total_ms);
    printf("max adapt iters  : %d\n", max_adapt_iters);
    printf("validate         : %d\n", do_validate);
    printf("validate tol     : %.3e\n", validate_tol);
    printf("validate strict  : %d\n", validate_strict);
    printf("stream mode      : %d\n", stream_mode);
    printf("stream target MB : %.1f\n", stream_target_mb);
    printf("stream min slots : %d\n", stream_min_slots);
    printf("stream max slots : %d\n", stream_max_slots);
    printf("mem cap (MB)     : %.1f\n", max_mem_mb);
    printf("threads_field    : %d\n", threads_field);
    print_list("lengths", lengths, n_lengths);
    print_list("batches", batches, n_batches);
    printf("gpu_name         : %s\n", prop.name);
    printf("compute_cap      : %d.%d\n", prop.major, prop.minor);
    printf("sm_count         : %d\n", prop.multiProcessorCount);
    printf("warp_size        : %d\n", prop.warpSize);
    printf("max_threads_sm   : %d\n", prop.maxThreadsPerMultiProcessor);
    printf("max_threads_blk  : %d\n", prop.maxThreadsPerBlock);
    printf("global_mem_mb    : %.1f\n", (double)prop.totalGlobalMem / (1024.0 * 1024.0));
    printf("\n");

    if (strcmp(workload, "throughput") == 0 || strcmp(workload, "all") == 0) {
        run_throughput(profile_id,
                       threads_field,
                       warmup_runs,
                       nruns,
                       max_mem_mb,
                       min_total_ms,
                       max_adapt_iters,
                       do_validate,
                       validate_tol,
                       validate_strict,
                       stream_mode,
                       stream_target_mb,
                       stream_min_slots,
                       stream_max_slots,
                       lengths,
                       n_lengths,
                       batches,
                       n_batches);
    } else {
        fprintf(stderr, "ERROR: unknown BENCH_WORKLOAD='%s' (expected throughput|all)\n", workload);
        return 2;
    }

    ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: final cudaDeviceSynchronize failed: %s\n", cudaGetErrorString(ce));
        return 1;
    }

    printf("\nBenchmark workload complete.\n\n");
    return 0;
}
