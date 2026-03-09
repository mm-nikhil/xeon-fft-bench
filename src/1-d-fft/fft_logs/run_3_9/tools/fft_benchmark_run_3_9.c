/*
 * fft_benchmark.c
 * Intel oneMKL 1D complex FFT benchmark with workload-based execution.
 */

#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <math.h>
#include <mkl.h>
#include <mkl_dfti.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAX_LIST 64

static double get_time_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1.0e6;
}

static void random_init_2d(MKL_Complex8 *data, int howmany, int n, unsigned int seed)
{
    srand(seed);
    for (int b = 0; b < howmany; b++) {
        for (int i = 0; i < n; i++) {
            MKL_LONG idx = (MKL_LONG)b * (MKL_LONG)n + (MKL_LONG)i;
            data[idx].real = (float)rand() / (float)RAND_MAX;
            data[idx].imag = (float)rand() / (float)RAND_MAX;
        }
    }
}

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

static MKL_LONG timed_forward_adaptive(DFTI_DESCRIPTOR_HANDLE plan,
                                       MKL_Complex8 *in_pool,
                                       MKL_Complex8 *out_pool,
                                       MKL_LONG total,
                                       int stream_slots,
                                       int warmup_runs,
                                       int nruns,
                                       double min_total_ms,
                                       int max_adapt_iters,
                                       double *avg_ms_out,
                                       int *timed_iters_out)
{
    MKL_LONG status = DFTI_NO_ERROR;
    int timed_iters = nruns > 0 ? nruns : 1;
    if (timed_iters > max_adapt_iters) timed_iters = max_adapt_iters;

    for (int i = 0; i < warmup_runs; i++) {
        int slot = stream_slots > 1 ? (i % stream_slots) : 0;
        MKL_Complex8 *in = in_pool + (MKL_LONG)slot * total;
        MKL_Complex8 *out = out_pool + (MKL_LONG)slot * total;
        status = DftiComputeForward(plan, in, out);
        if (status != DFTI_NO_ERROR) return status;
    }

    double elapsed_ms = 0.0;
    for (;;) {
        double t0 = get_time_ms();
        for (int i = 0; i < timed_iters; i++) {
            int slot = stream_slots > 1 ? (i % stream_slots) : 0;
            MKL_Complex8 *in = in_pool + (MKL_LONG)slot * total;
            MKL_Complex8 *out = out_pool + (MKL_LONG)slot * total;
            status = DftiComputeForward(plan, in, out);
            if (status != DFTI_NO_ERROR) return status;
        }
        elapsed_ms = get_time_ms() - t0;
        if (elapsed_ms >= min_total_ms || timed_iters >= max_adapt_iters) break;

        double safe_elapsed = elapsed_ms > 1.0e-3 ? elapsed_ms : 1.0e-3;
        long long candidate = (long long)ceil((double)timed_iters * (min_total_ms / safe_elapsed));
        if (candidate <= timed_iters) candidate = (long long)timed_iters * 2LL;
        if (candidate > (long long)max_adapt_iters) candidate = (long long)max_adapt_iters;
        timed_iters = (int)candidate;
    }

    if (elapsed_ms <= 0.0) elapsed_ms = 1.0e-6;
    *avg_ms_out = elapsed_ms / (double)timed_iters;
    *timed_iters_out = timed_iters;
    return DFTI_NO_ERROR;
}

static MKL_LONG timed_backward_adaptive(DFTI_DESCRIPTOR_HANDLE plan,
                                        MKL_Complex8 *out_pool,
                                        MKL_Complex8 *in_pool,
                                        MKL_LONG total,
                                        int stream_slots,
                                        int warmup_runs,
                                        int nruns,
                                        double min_total_ms,
                                        int max_adapt_iters,
                                        double *avg_ms_out,
                                        int *timed_iters_out)
{
    MKL_LONG status = DFTI_NO_ERROR;
    int timed_iters = nruns > 0 ? nruns : 1;
    if (timed_iters > max_adapt_iters) timed_iters = max_adapt_iters;

    for (int i = 0; i < warmup_runs; i++) {
        int slot = stream_slots > 1 ? (i % stream_slots) : 0;
        MKL_Complex8 *out = out_pool + (MKL_LONG)slot * total;
        MKL_Complex8 *in = in_pool + (MKL_LONG)slot * total;
        status = DftiComputeBackward(plan, out, in);
        if (status != DFTI_NO_ERROR) return status;
    }

    double elapsed_ms = 0.0;
    for (;;) {
        double t0 = get_time_ms();
        for (int i = 0; i < timed_iters; i++) {
            int slot = stream_slots > 1 ? (i % stream_slots) : 0;
            MKL_Complex8 *out = out_pool + (MKL_LONG)slot * total;
            MKL_Complex8 *in = in_pool + (MKL_LONG)slot * total;
            status = DftiComputeBackward(plan, out, in);
            if (status != DFTI_NO_ERROR) return status;
        }
        elapsed_ms = get_time_ms() - t0;
        if (elapsed_ms >= min_total_ms || timed_iters >= max_adapt_iters) break;

        double safe_elapsed = elapsed_ms > 1.0e-3 ? elapsed_ms : 1.0e-3;
        long long candidate = (long long)ceil((double)timed_iters * (min_total_ms / safe_elapsed));
        if (candidate <= timed_iters) candidate = (long long)timed_iters * 2LL;
        if (candidate > (long long)max_adapt_iters) candidate = (long long)max_adapt_iters;
        timed_iters = (int)candidate;
    }

    if (elapsed_ms <= 0.0) elapsed_ms = 1.0e-6;
    *avg_ms_out = elapsed_ms / (double)timed_iters;
    *timed_iters_out = timed_iters;
    return DFTI_NO_ERROR;
}

static int validate_roundtrip(const char *profile_id,
                              const char *workload,
                              const char *case_id,
                              int n,
                              int howmany,
                              int num_threads,
                              DFTI_DESCRIPTOR_HANDLE plan,
                              MKL_Complex8 *in,
                              MKL_Complex8 *out,
                              const MKL_Complex8 *orig,
                              double tol)
{
    MKL_LONG status = DftiComputeForward(plan, in, out);
    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: validation forward failed: %ld\n", status);
        return -1;
    }
    status = DftiComputeBackward(plan, out, in);
    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: validation backward failed: %ld\n", status);
        return -1;
    }

    MKL_LONG total = (MKL_LONG)n * (MKL_LONG)howmany;
    double inv_n = 1.0 / (double)n;
    double sum_ref2 = 0.0;
    double sum_err2 = 0.0;
    double max_abs = 0.0;
    for (MKL_LONG i = 0; i < total; i++) {
        double rr = (double)orig[i].real;
        double ri = (double)orig[i].imag;
        double xr = (double)in[i].real * inv_n;
        double xi = (double)in[i].imag * inv_n;
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
           profile_id, workload, case_id,
           n, 1, 1, howmany, num_threads,
           rel_rms, max_abs, tol,
           pass ? "PASS" : "FAIL");
    fflush(stdout);
    return pass ? 1 : 0;
}

static void run_benchmark(const char *profile_id,
                          const char *workload,
                          const char *case_id,
                          int n,
                          int howmany,
                          int num_threads,
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
    mkl_set_num_threads(num_threads);

    MKL_LONG distance = (MKL_LONG)n;
    MKL_LONG total = (MKL_LONG)howmany * distance;
    double single_slot_mb = (2.0 * (double)total * (double)sizeof(MKL_Complex8)) / (1024.0 * 1024.0);
    size_t elem_bytes = sizeof(MKL_Complex8);
    size_t tensor_bytes = (size_t)total * elem_bytes;
    size_t slot_bytes = tensor_bytes * 2U;
    size_t orig_bytes = tensor_bytes;

    int stream_slots = 1;
    if (stream_mode) {
        double target_bytes_d = stream_target_mb * 1024.0 * 1024.0;
        size_t target_bytes = target_bytes_d > 0.0 ? (size_t)target_bytes_d : 1U;
        stream_slots = (int)((target_bytes + slot_bytes - 1U) / slot_bytes);
        if (stream_slots < stream_min_slots) stream_slots = stream_min_slots;
        if (stream_slots > stream_max_slots) stream_slots = stream_max_slots;
    }

    if (stream_slots < 1) stream_slots = 1;

    if (max_mem_mb > 0.0) {
        size_t max_bytes = (size_t)(max_mem_mb * 1024.0 * 1024.0);
        if (max_bytes <= orig_bytes + slot_bytes) {
            printf("[skip] %-16s | Len:%7d | Batch:%6d | Thr:%2d | Mem:%.1f MB exceeds cap %.1f MB\n",
                   case_id, n, howmany, num_threads, single_slot_mb, max_mem_mb);
            printf("SKIP|%s|%s|%s|%d|%d|%d|%d|%d|%.2f|memory_limit\n",
                   profile_id, workload, case_id,
                   n, 1, 1, howmany, num_threads,
                   single_slot_mb);
            fflush(stdout);
            return;
        }

        size_t max_slots_by_mem = (max_bytes - orig_bytes) / slot_bytes;
        if (max_slots_by_mem == 0) max_slots_by_mem = 1;
        if ((size_t)stream_slots > max_slots_by_mem) stream_slots = (int)max_slots_by_mem;
    }

    double working_mem_mb = ((double)orig_bytes + (double)stream_slots * (double)slot_bytes) / (1024.0 * 1024.0);

    if (max_mem_mb > 0.0 && working_mem_mb > max_mem_mb) {
        printf("[skip] %-16s | Len:%7d | Batch:%6d | Thr:%2d | Mem:%7.1f MB > limit %.1f MB\n",
               case_id, n, howmany, num_threads, working_mem_mb, max_mem_mb);
        printf("SKIP|%s|%s|%s|%d|%d|%d|%d|%d|%.2f|memory_limit\n",
               profile_id, workload, case_id,
               n, 1, 1, howmany, num_threads,
               working_mem_mb);
        fflush(stdout);
        return;
    }

    MKL_Complex8 *in_pool = (MKL_Complex8 *)mkl_malloc((size_t)stream_slots * tensor_bytes, 64);
    MKL_Complex8 *out_pool = (MKL_Complex8 *)mkl_malloc((size_t)stream_slots * tensor_bytes, 64);
    MKL_Complex8 *orig = (MKL_Complex8 *)mkl_malloc(tensor_bytes, 64);
    if (!in_pool || !out_pool || !orig) {
        fprintf(stderr, "ERROR: allocation failed for n=%d batch=%d (%.1f MB)\n",
                n, howmany, working_mem_mb);
        mkl_free(in_pool);
        mkl_free(out_pool);
        mkl_free(orig);
        return;
    }

    for (int s = 0; s < stream_slots; s++) {
        MKL_Complex8 *in = in_pool + (MKL_LONG)s * total;
        MKL_Complex8 *out = out_pool + (MKL_LONG)s * total;
        unsigned int seed = 42U + (unsigned int)(s * 10007U) + (unsigned int)(n * 7 + howmany);
        random_init_2d(in, howmany, n, seed);
        memset(out, 0, tensor_bytes);
    }
    memcpy(orig, in_pool, tensor_bytes);

    DFTI_DESCRIPTOR_HANDLE plan = NULL;
    MKL_LONG len = (MKL_LONG)n;
    MKL_LONG status = DftiCreateDescriptor(&plan, DFTI_SINGLE, DFTI_COMPLEX, 1, len);
    status |= DftiSetValue(plan, DFTI_NUMBER_OF_TRANSFORMS, (MKL_LONG)howmany);
    status |= DftiSetValue(plan, DFTI_INPUT_DISTANCE, distance);
    status |= DftiSetValue(plan, DFTI_OUTPUT_DISTANCE, distance);
    status |= DftiSetValue(plan, DFTI_PLACEMENT, DFTI_NOT_INPLACE);
    status |= DftiCommitDescriptor(plan);

    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: DFTI descriptor setup failed: %ld\n", status);
        DftiFreeDescriptor(&plan);
        mkl_free(in_pool);
        mkl_free(out_pool);
        mkl_free(orig);
        return;
    }

    if (do_validate) {
        MKL_Complex8 *vin = in_pool;
        MKL_Complex8 *vout = out_pool;
        int ok = validate_roundtrip(profile_id,
                                    workload,
                                    case_id,
                                    n,
                                    howmany,
                                    num_threads,
                                    plan,
                                    vin,
                                    vout,
                                    orig,
                                    validate_tol);
        if (ok < 0) {
            DftiFreeDescriptor(&plan);
            mkl_free(in_pool);
            mkl_free(out_pool);
            mkl_free(orig);
            return;
        }
        if (ok == 0 && validate_strict) {
            fprintf(stderr, "ERROR: validation failed (strict mode) for %s\n", case_id);
            DftiFreeDescriptor(&plan);
            mkl_free(in_pool);
            mkl_free(out_pool);
            mkl_free(orig);
            return;
        }
        memcpy(vin, orig, tensor_bytes);
        memset(vout, 0, tensor_bytes);
    }

    double fwd_ms = 0.0;
    double bwd_ms = 0.0;
    int fwd_iters = 0;
    int bwd_iters = 0;

    status = timed_forward_adaptive(plan,
                                    in_pool,
                                    out_pool,
                                    total,
                                    stream_slots,
                                    warmup_runs,
                                    nruns,
                                    min_total_ms,
                                    max_adapt_iters,
                                    &fwd_ms,
                                    &fwd_iters);
    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: timed forward failed: %ld\n", status);
        DftiFreeDescriptor(&plan);
        mkl_free(in_pool);
        mkl_free(out_pool);
        mkl_free(orig);
        return;
    }

    status = timed_backward_adaptive(plan,
                                     out_pool,
                                     in_pool,
                                     total,
                                     stream_slots,
                                     warmup_runs,
                                     nruns,
                                     min_total_ms,
                                     max_adapt_iters,
                                     &bwd_ms,
                                     &bwd_iters);
    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: timed backward failed: %ld\n", status);
        DftiFreeDescriptor(&plan);
        mkl_free(in_pool);
        mkl_free(out_pool);
        mkl_free(orig);
        return;
    }

    double n_total = (double)n;
    double flops = 5.0 * n_total * log2(n_total) * (double)howmany;
    double fwd_gflops = flops / (fwd_ms * 1.0e6);
    double bwd_gflops = flops / (bwd_ms * 1.0e6);
    printf("[run ] %-16s | Len:%7d | Batch:%6d | Thr:%2d | "
           "Fwd:%10.4f ms %8.2f GF/s (iters:%d) | "
           "Bwd:%10.4f ms %8.2f GF/s (iters:%d) | Slots:%3d | Mem:%7.2f MB\n",
           case_id,
           n, howmany, num_threads,
           fwd_ms, fwd_gflops,
           fwd_iters,
           bwd_ms, bwd_gflops,
           bwd_iters,
           stream_slots,
           working_mem_mb);

    // Keep output field count aligned with the 3D parser: nx=n, ny=1, nz=1.
    printf("RESULT|%s|%s|%s|%d|%d|%d|%d|%d|%.6f|%.6f|%.6f|%.6f|%.2f\n",
           profile_id,
           workload,
           case_id,
           n, 1, 1,
           howmany,
           num_threads,
           fwd_ms,
           fwd_gflops,
           bwd_ms,
           bwd_gflops,
           working_mem_mb);
    fflush(stdout);

    DftiFreeDescriptor(&plan);
    mkl_free(in_pool);
    mkl_free(out_pool);
    mkl_free(orig);
}

static void run_throughput(const char *profile_id,
                           int threads,
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
    section("WORKLOAD: throughput (length x batch at fixed thread count)");
    printf("threads=%d\n", threads);

    for (int i = 0; i < n_lengths; i++) {
        for (int j = 0; j < n_batches; j++) {
            char case_id[64];
            snprintf(case_id, sizeof(case_id), "n%d_b%d", lengths[i], batches[j]);
            run_benchmark(profile_id,
                          "throughput",
                          case_id,
                          lengths[i],
                          batches[j],
                          threads,
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

static void run_thread_scaling(const char *profile_id,
                               int length,
                               int batch,
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
                               const int *threads,
                               int n_threads)
{
    section("WORKLOAD: thread_scaling (fixed length/batch, vary threads)");
    printf("length=%d batch=%d\n", length, batch);

    for (int i = 0; i < n_threads; i++) {
        char case_id[64];
        snprintf(case_id, sizeof(case_id), "n%d_b%d_t%d", length, batch, threads[i]);
        run_benchmark(profile_id,
                      "thread_scaling",
                      case_id,
                      length,
                      batch,
                      threads[i],
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

static void run_batch_scaling(const char *profile_id,
                              int length,
                              int threads,
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
                              const int *batches,
                              int n_batches)
{
    section("WORKLOAD: batch_scaling (fixed length/threads, vary batch)");
    printf("length=%d threads=%d\n", length, threads);

    for (int i = 0; i < n_batches; i++) {
        char case_id[64];
        snprintf(case_id, sizeof(case_id), "n%d_b%d_t%d", length, batches[i], threads);
        run_benchmark(profile_id,
                      "batch_scaling",
                      case_id,
                      length,
                      batches[i],
                      threads,
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

int main(int argc, char **argv)
{
    int cli_threads = (argc > 1) ? atoi(argv[1]) : 1;
    if (cli_threads < 1) cli_threads = 1;

    int max_threads = mkl_get_max_threads();
    int nruns = env_int("BENCH_NRUNS", 20, 1, 1000000);
    int warmup_runs = env_int("BENCH_WARMUP", 5, 0, 1000000);
    double max_mem_mb = env_double("BENCH_MAX_MEM_MB", 3072.0, 0.0, 262144.0);
    double min_total_ms = env_double("BENCH_MIN_TOTAL_MS", 50.0, 1.0, 600000.0);
    int max_adapt_iters = env_int("BENCH_MAX_ADAPT_ITERS", 100000000, 1, 1000000000);
    int do_validate = env_int("BENCH_VALIDATE", 1, 0, 1);
    double validate_tol = env_double("BENCH_VALIDATE_TOL", 1e-4, 1e-12, 1.0);
    int validate_strict = env_int("BENCH_VALIDATE_STRICT", 1, 0, 1);
    int stream_mode = env_int("BENCH_STREAM_MODE", 1, 0, 1);
    double stream_target_mb = env_double("BENCH_STREAM_TARGET_MB", 128.0, 1.0, 65536.0);
    int stream_min_slots = env_int("BENCH_STREAM_MIN_SLOTS", 2, 1, 16384);
    int stream_max_slots = env_int("BENCH_STREAM_MAX_SLOTS", 256, 1, 16384);

    const char *profile_id = getenv("BENCH_PROFILE");
    if (!profile_id || !*profile_id) profile_id = "manual";

    const char *profile_desc = getenv("BENCH_PROFILE_DESC");
    if (!profile_desc || !*profile_desc) profile_desc = "manual run";

    const char *workload = getenv("BENCH_WORKLOAD");
    if (!workload || !*workload) workload = "throughput";

    int lengths[MAX_LIST];
    int batches[MAX_LIST];
    int thread_set[MAX_LIST];
    int batch_scale_set[MAX_LIST];

    int n_lengths = load_int_list("BENCH_LENGTHS", "1024,4096,16384,65536,262144", lengths, MAX_LIST, 2, 1 << 26);
    int n_batches = load_int_list("BENCH_BATCHES", "1,10,16,150,256,1024", batches, MAX_LIST, 1, 1 << 20);
    int n_thread_set = load_int_list("BENCH_THREAD_SET", "1,2,4,8,10,20", thread_set, MAX_LIST, 1, 4096);
    int n_batch_scale = load_int_list("BENCH_BATCH_SCALE_SET", "1,4,16,64,256", batch_scale_set, MAX_LIST, 1, 1 << 20);

    if (n_lengths <= 0) {
        lengths[0] = 1024; lengths[1] = 4096; lengths[2] = 16384;
        n_lengths = 3;
    }
    if (n_batches <= 0) {
        batches[0] = 1; batches[1] = 10; batches[2] = 16;
        batches[3] = 150; batches[4] = 256; batches[5] = 1024;
        n_batches = 6;
    }
    if (n_thread_set <= 0) {
        thread_set[0] = 1; thread_set[1] = 2; thread_set[2] = 4; thread_set[3] = 8;
        n_thread_set = 4;
    }
    if (n_batch_scale <= 0) {
        batch_scale_set[0] = 1; batch_scale_set[1] = 4; batch_scale_set[2] = 16;
        n_batch_scale = 3;
    }

    int scale_length = env_int("BENCH_SCALE_LENGTH", 16384, 2, 1 << 26);
    int scale_batch = env_int("BENCH_SCALE_BATCH", 64, 1, 1 << 20);
    int scale_threads = env_int("BENCH_SCALE_THREADS", cli_threads, 1, 4096);

    printf("\n############################################################\n");
    printf("# FFT BENCHMARK (Intel oneMKL DFTI, 1D, single precision)  #\n");
    printf("############################################################\n");
    printf("profile_id       : %s\n", profile_id);
    printf("profile_desc     : %s\n", profile_desc);
    printf("workload         : %s\n", workload);
    printf("threads(cli)     : %d\n", cli_threads);
    printf("mkl max threads  : %d\n", max_threads);
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
    print_list("lengths", lengths, n_lengths);
    print_list("batches", batches, n_batches);
    print_list("thread_set", thread_set, n_thread_set);
    print_list("batch_scale_set", batch_scale_set, n_batch_scale);
    printf("scale_length     : %d\n", scale_length);
    printf("scale_batch      : %d\n", scale_batch);
    printf("scale_threads    : %d\n", scale_threads);
    printf("\n");

    if (strcmp(workload, "throughput") == 0) {
        run_throughput(profile_id,
                       cli_threads,
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
    } else if (strcmp(workload, "thread_scaling") == 0) {
        run_thread_scaling(profile_id,
                           scale_length,
                           scale_batch,
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
                           thread_set,
                           n_thread_set);
    } else if (strcmp(workload, "batch_scaling") == 0) {
        run_batch_scaling(profile_id,
                          scale_length,
                          scale_threads,
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
                          batch_scale_set,
                          n_batch_scale);
    } else if (strcmp(workload, "all") == 0) {
        run_throughput(profile_id,
                       cli_threads,
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

        run_thread_scaling(profile_id,
                           scale_length,
                           scale_batch,
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
                           thread_set,
                           n_thread_set);

        run_batch_scaling(profile_id,
                          scale_length,
                          scale_threads,
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
                          batch_scale_set,
                          n_batch_scale);
    } else {
        fprintf(stderr,
                "ERROR: unknown BENCH_WORKLOAD='%s' (expected throughput|thread_scaling|batch_scaling|all)\n",
                workload);
        return 2;
    }

    printf("\nBenchmark workload complete.\n\n");
    return 0;
}
