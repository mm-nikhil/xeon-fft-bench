/*
 * fft_benchmark.cu
 * cuFFT 1D complex FFT benchmark with workload-based execution.
 */

#include <ctype.h>
#include <cuda_runtime.h>
#include <cufft.h>
#include <math.h>
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
    default: return "CUFFT_UNKNOWN_ERROR";
    }
}

static void emit_skip(const char *profile_id,
                      const char *workload,
                      const char *case_id,
                      int n,
                      int howmany,
                      int threads_field,
                      double mem_mb,
                      const char *reason)
{
    printf("[skip] %-16s | Len:%7d | Batch:%6d | Thr:%2d | Mem:%7.2f MB | Reason:%s\n",
           case_id, n, howmany, threads_field, mem_mb, reason);
    printf("SKIP|%s|%s|%s|%d|%d|%d|%d|%d|%.2f|%s\n",
           profile_id, workload, case_id,
           n, 1, 1, howmany, threads_field,
           mem_mb, reason);
    fflush(stdout);
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
                          int include_transfers,
                          const char *timing_mode)
{
    size_t total = (size_t)n * (size_t)howmany;
    size_t bytes = total * sizeof(cufftComplex);
    double mem_mb = (2.0 * (double)bytes) / (1024.0 * 1024.0);
    cufftComplex *d_in = NULL;
    cufftComplex *d_out = NULL;
    cufftComplex *h_in = NULL;
    cufftComplex *h_out = NULL;
    cufftHandle plan;
    int plan_created = 0;
    int rank = 1;
    int dims[1] = {0};
    int ok = 1;
    cudaError_t ce;
    cufftResult cr;
    double fwd_ms = 0.0;
    double bwd_ms = 0.0;

    if (max_mem_mb > 0.0 && mem_mb > max_mem_mb) {
        emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "memory_limit");
        return;
    }

    ce = cudaMalloc((void **)&d_in, bytes);
    if (ce != cudaSuccess) {
        emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "cuda_malloc_in_failed");
        return;
    }
    ce = cudaMalloc((void **)&d_out, bytes);
    if (ce != cudaSuccess) {
        emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "cuda_malloc_out_failed");
        goto cleanup;
    }

    if (include_transfers) {
        ce = cudaMallocHost((void **)&h_in, bytes);
        if (ce != cudaSuccess) {
            emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "cuda_malloc_host_in_failed");
            goto cleanup;
        }
        ce = cudaMallocHost((void **)&h_out, bytes);
        if (ce != cudaSuccess) {
            emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "cuda_malloc_host_out_failed");
            goto cleanup;
        }
        for (size_t i = 0; i < total; i++) {
            h_in[i].x = (float)(i % 1024u) / 1024.0f;
            h_in[i].y = (float)((i * 7u) % 1024u) / 1024.0f;
            h_out[i].x = 0.0f;
            h_out[i].y = 0.0f;
        }
    } else {
        ce = cudaMemset(d_in, 0, bytes);
        if (ce != cudaSuccess) {
            emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "cuda_memset_failed");
            goto cleanup;
        }
        ce = cudaMemset(d_out, 0, bytes);
        if (ce != cudaSuccess) {
            emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "cuda_memset_failed");
            goto cleanup;
        }
    }

    dims[0] = n;
    cr = cufftPlanMany(&plan, rank, dims, NULL, 1, n, NULL, 1, n, CUFFT_C2C, howmany);
    if (cr != CUFFT_SUCCESS) {
        emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, cufft_status_string(cr));
        goto cleanup;
    }
    plan_created = 1;

    for (int i = 0; i < warmup_runs; i++) {
        if (include_transfers) {
            ce = cudaMemcpyAsync(d_in, h_in, bytes, cudaMemcpyHostToDevice, 0);
            if (ce != cudaSuccess) {
                fprintf(stderr, "ERROR: warmup H2D failed for %s: %s\n", case_id, cudaGetErrorString(ce));
                ok = 0;
                break;
            }
        }
        cr = cufftExecC2C(plan, d_in, d_out, CUFFT_FORWARD);
        if (cr != CUFFT_SUCCESS) {
            fprintf(stderr, "ERROR: warmup forward failed for %s: %s\n", case_id, cufft_status_string(cr));
            ok = 0;
            break;
        }
        if (include_transfers) {
            ce = cudaMemcpyAsync(h_out, d_out, bytes, cudaMemcpyDeviceToHost, 0);
            if (ce != cudaSuccess) {
                fprintf(stderr, "ERROR: warmup D2H failed for %s: %s\n", case_id, cudaGetErrorString(ce));
                ok = 0;
                break;
            }
        }
    }
    if (ok) {
        ce = cudaDeviceSynchronize();
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: warmup synchronize failed for %s: %s\n", case_id, cudaGetErrorString(ce));
            ok = 0;
        }
    }

    if (ok) {
        cudaEvent_t ev_start, ev_end;
        ce = cudaEventCreate(&ev_start);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventCreate(start) failed for %s: %s\n", case_id, cudaGetErrorString(ce));
            ok = 0;
        }
        ce = cudaEventCreate(&ev_end);
        if (ce != cudaSuccess) {
            fprintf(stderr, "ERROR: cudaEventCreate(end) failed for %s: %s\n", case_id, cudaGetErrorString(ce));
            if (ok) cudaEventDestroy(ev_start);
            ok = 0;
        }

        if (ok) {
            float fwd_total_ms = 0.0f;
            float bwd_total_ms = 0.0f;

            ce = cudaEventRecord(ev_start);
            if (ce != cudaSuccess) {
                fprintf(stderr, "ERROR: cudaEventRecord(start) failed for %s: %s\n",
                        case_id, cudaGetErrorString(ce));
                ok = 0;
            }
            for (int i = 0; i < nruns; i++) {
                if (include_transfers) {
                    ce = cudaMemcpyAsync(d_in, h_in, bytes, cudaMemcpyHostToDevice, 0);
                    if (ce != cudaSuccess) {
                        fprintf(stderr, "ERROR: timed H2D(forward) failed for %s: %s\n",
                                case_id, cudaGetErrorString(ce));
                        ok = 0;
                        break;
                    }
                }
                cr = cufftExecC2C(plan, d_in, d_out, CUFFT_FORWARD);
                if (cr != CUFFT_SUCCESS) {
                    fprintf(stderr, "ERROR: timed forward failed for %s: %s\n", case_id, cufft_status_string(cr));
                    ok = 0;
                    break;
                }
                if (include_transfers) {
                    ce = cudaMemcpyAsync(h_out, d_out, bytes, cudaMemcpyDeviceToHost, 0);
                    if (ce != cudaSuccess) {
                        fprintf(stderr, "ERROR: timed D2H(forward) failed for %s: %s\n",
                                case_id, cudaGetErrorString(ce));
                        ok = 0;
                        break;
                    }
                }
            }
            if (ok) {
                ce = cudaEventRecord(ev_end);
                if (ce != cudaSuccess) {
                    fprintf(stderr, "ERROR: cudaEventRecord(end) failed for %s: %s\n",
                            case_id, cudaGetErrorString(ce));
                    ok = 0;
                }
            }
            if (ok) {
                ce = cudaEventSynchronize(ev_end);
                if (ce != cudaSuccess) {
                    fprintf(stderr, "ERROR: cudaEventSynchronize(end) failed for %s: %s\n",
                            case_id, cudaGetErrorString(ce));
                    ok = 0;
                }
            }
            if (ok) {
                ce = cudaEventElapsedTime(&fwd_total_ms, ev_start, ev_end);
                if (ce != cudaSuccess) {
                    fprintf(stderr, "ERROR: cudaEventElapsedTime(fwd) failed for %s: %s\n",
                            case_id, cudaGetErrorString(ce));
                    ok = 0;
                }
            }

            if (ok) {
                ce = cudaEventRecord(ev_start);
                if (ce != cudaSuccess) {
                    fprintf(stderr, "ERROR: cudaEventRecord(start,bwd) failed for %s: %s\n",
                            case_id, cudaGetErrorString(ce));
                    ok = 0;
                }
            }
            if (ok) {
                for (int i = 0; i < nruns; i++) {
                    if (include_transfers) {
                        ce = cudaMemcpyAsync(d_out, h_out, bytes, cudaMemcpyHostToDevice, 0);
                        if (ce != cudaSuccess) {
                            fprintf(stderr, "ERROR: timed H2D(backward) failed for %s: %s\n",
                                    case_id, cudaGetErrorString(ce));
                            ok = 0;
                            break;
                        }
                    }
                    cr = cufftExecC2C(plan, d_out, d_in, CUFFT_INVERSE);
                    if (cr != CUFFT_SUCCESS) {
                        fprintf(stderr, "ERROR: timed backward failed for %s: %s\n", case_id, cufft_status_string(cr));
                        ok = 0;
                        break;
                    }
                    if (include_transfers) {
                        ce = cudaMemcpyAsync(h_in, d_in, bytes, cudaMemcpyDeviceToHost, 0);
                        if (ce != cudaSuccess) {
                            fprintf(stderr, "ERROR: timed D2H(backward) failed for %s: %s\n",
                                    case_id, cudaGetErrorString(ce));
                            ok = 0;
                            break;
                        }
                    }
                }
                if (ok) {
                    ce = cudaEventRecord(ev_end);
                    if (ce != cudaSuccess) {
                        fprintf(stderr, "ERROR: cudaEventRecord(end,bwd) failed for %s: %s\n",
                                case_id, cudaGetErrorString(ce));
                        ok = 0;
                    }
                }
                if (ok) {
                    ce = cudaEventSynchronize(ev_end);
                    if (ce != cudaSuccess) {
                        fprintf(stderr, "ERROR: cudaEventSynchronize(end,bwd) failed for %s: %s\n",
                                case_id, cudaGetErrorString(ce));
                        ok = 0;
                    }
                }
                if (ok) {
                    ce = cudaEventElapsedTime(&bwd_total_ms, ev_start, ev_end);
                    if (ce != cudaSuccess) {
                        fprintf(stderr, "ERROR: cudaEventElapsedTime(bwd) failed for %s: %s\n",
                                case_id, cudaGetErrorString(ce));
                        ok = 0;
                    }
                }
            }

            fwd_ms = (double)fwd_total_ms / (double)nruns;
            bwd_ms = (double)bwd_total_ms / (double)nruns;

            cudaEventDestroy(ev_start);
            cudaEventDestroy(ev_end);
        }
    }

    if (ok && fwd_ms > 0.0 && bwd_ms > 0.0) {
        double flops = 5.0 * (double)n * log2((double)n) * (double)howmany;
        double fwd_gflops = flops / (fwd_ms * 1.0e6);
        double bwd_gflops = flops / (bwd_ms * 1.0e6);
        printf("[run ] %-16s | Mode:%-7s | Len:%7d | Batch:%6d | Thr:%2d | "
               "Fwd:%10.4f ms %8.2f GF/s | Bwd:%10.4f ms %8.2f GF/s | Mem:%7.2f MB\n",
               case_id, timing_mode, n, howmany, threads_field, fwd_ms, fwd_gflops, bwd_ms, bwd_gflops, mem_mb);
        printf("RESULT|%s|%s|%s|%d|%d|%d|%d|%d|%.6f|%.6f|%.6f|%.6f|%.2f\n",
               profile_id, workload, case_id, n, 1, 1, howmany, threads_field,
               fwd_ms, fwd_gflops, bwd_ms, bwd_gflops, mem_mb);
    } else {
        emit_skip(profile_id, workload, case_id, n, howmany, threads_field, mem_mb, "execution_failed");
    }
    fflush(stdout);

cleanup:
    if (plan_created) cufftDestroy(plan);
    if (h_in) cudaFreeHost(h_in);
    if (h_out) cudaFreeHost(h_out);
    if (d_in) cudaFree(d_in);
    if (d_out) cudaFree(d_out);
}

static void run_throughput(const char *profile_id,
                           int threads_field,
                           int warmup_runs,
                           int nruns,
                           double max_mem_mb,
                           int include_transfers,
                           const char *timing_mode,
                           const int *lengths,
                           int n_lengths,
                           const int *batches,
                           int n_batches)
{
    section("WORKLOAD: throughput (length x batch at fixed thread field)");
    printf("threads_field=%d\n", threads_field);

    for (int i = 0; i < n_lengths; i++) {
        for (int j = 0; j < n_batches; j++) {
            char case_id[64];
            snprintf(case_id, sizeof(case_id), "n%d_b%d", lengths[i], batches[j]);
            run_benchmark(profile_id, "throughput", case_id, lengths[i], batches[j],
                          threads_field, warmup_runs, nruns, max_mem_mb,
                          include_transfers, timing_mode);
        }
    }
}

static void run_batch_scaling(const char *profile_id,
                              int length,
                              int threads_field,
                              int warmup_runs,
                              int nruns,
                              double max_mem_mb,
                              int include_transfers,
                              const char *timing_mode,
                              const int *batches,
                              int n_batches)
{
    section("WORKLOAD: batch_scaling (fixed length, vary batch)");
    printf("length=%d threads_field=%d\n", length, threads_field);

    for (int i = 0; i < n_batches; i++) {
        char case_id[64];
        snprintf(case_id, sizeof(case_id), "n%d_b%d_t%d", length, batches[i], threads_field);
        run_benchmark(profile_id, "batch_scaling", case_id, length, batches[i],
                      threads_field, warmup_runs, nruns, max_mem_mb,
                      include_transfers, timing_mode);
    }
}

int main(void)
{
    int nruns = env_int("BENCH_NRUNS", 20, 1, 1000000);
    int warmup_runs = env_int("BENCH_WARMUP", 5, 0, 1000000);
    double max_mem_mb = env_double("BENCH_MAX_MEM_MB", 8192.0, 0.0, 262144.0);
    int threads_field = env_int("BENCH_THREADS_FIELD", 1, 1, 65535);

    const char *profile_id = getenv("BENCH_PROFILE");
    if (!profile_id || !*profile_id) profile_id = "manual";
    const char *profile_desc = getenv("BENCH_PROFILE_DESC");
    if (!profile_desc || !*profile_desc) profile_desc = "manual run";
    const char *workload = getenv("BENCH_WORKLOAD");
    if (!workload || !*workload) workload = "throughput";
    const char *timing_mode = getenv("BENCH_TIMING_MODE");
    if (!timing_mode || !*timing_mode) timing_mode = "compute";
    int include_transfers = 0;
    if (strcmp(timing_mode, "compute") == 0) {
        include_transfers = 0;
    } else if (strcmp(timing_mode, "e2e") == 0) {
        include_transfers = 1;
    } else {
        fprintf(stderr, "ERROR: unknown BENCH_TIMING_MODE='%s' (expected compute|e2e)\n", timing_mode);
        return 2;
    }

    int lengths[MAX_LIST];
    int batches[MAX_LIST];
    int batch_scale_set[MAX_LIST];
    int n_lengths = load_int_list("BENCH_LENGTHS",
                                  "32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304",
                                  lengths, MAX_LIST, 2, 1 << 26);
    int n_batches = load_int_list("BENCH_BATCHES", "1,4,16", batches, MAX_LIST, 1, 1 << 20);
    int n_batch_scale = load_int_list("BENCH_BATCH_SCALE_SET", "1,4,16,64,256",
                                      batch_scale_set, MAX_LIST, 1, 1 << 20);

    if (n_lengths <= 0) {
        lengths[0] = 1024; lengths[1] = 4096; lengths[2] = 16384;
        n_lengths = 3;
    }
    if (n_batches <= 0) {
        batches[0] = 1; batches[1] = 4; batches[2] = 16;
        n_batches = 3;
    }
    if (n_batch_scale <= 0) {
        batch_scale_set[0] = 1; batch_scale_set[1] = 4; batch_scale_set[2] = 16;
        n_batch_scale = 3;
    }

    int scale_length = env_int("BENCH_SCALE_LENGTH", 16384, 2, 1 << 26);

    int device_count = 0;
    cudaError_t ce = cudaGetDeviceCount(&device_count);
    if (ce != cudaSuccess || device_count <= 0) {
        fprintf(stderr, "ERROR: no CUDA devices available: %s\n", cudaGetErrorString(ce));
        return 1;
    }
    ce = cudaSetDevice(0);
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaSetDevice(0) failed: %s\n", cudaGetErrorString(ce));
        return 1;
    }

    cudaDeviceProp prop;
    ce = cudaGetDeviceProperties(&prop, 0);
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
    printf("timing_mode      : %s\n", timing_mode);
    printf("timed runs       : %d\n", nruns);
    printf("warmup runs      : %d\n", warmup_runs);
    printf("mem cap (MB)     : %.1f\n", max_mem_mb);
    printf("threads_field    : %d\n", threads_field);
    print_list("lengths", lengths, n_lengths);
    print_list("batches", batches, n_batches);
    print_list("batch_scale_set", batch_scale_set, n_batch_scale);
    printf("scale_length     : %d\n", scale_length);
    printf("gpu_name         : %s\n", prop.name);
    printf("compute_cap      : %d.%d\n", prop.major, prop.minor);
    printf("sm_count         : %d\n", prop.multiProcessorCount);
    printf("warp_size        : %d\n", prop.warpSize);
    printf("max_threads_sm   : %d\n", prop.maxThreadsPerMultiProcessor);
    printf("max_threads_blk  : %d\n", prop.maxThreadsPerBlock);
    printf("global_mem_mb    : %.1f\n", (double)prop.totalGlobalMem / (1024.0 * 1024.0));
    printf("\n");

    if (strcmp(workload, "throughput") == 0) {
        run_throughput(profile_id, threads_field, warmup_runs, nruns, max_mem_mb,
                       include_transfers, timing_mode,
                       lengths, n_lengths, batches, n_batches);
    } else if (strcmp(workload, "batch_scaling") == 0) {
        run_batch_scaling(profile_id, scale_length, threads_field, warmup_runs, nruns,
                          max_mem_mb, include_transfers, timing_mode,
                          batch_scale_set, n_batch_scale);
    } else if (strcmp(workload, "all") == 0) {
        run_throughput(profile_id, threads_field, warmup_runs, nruns, max_mem_mb,
                       include_transfers, timing_mode,
                       lengths, n_lengths, batches, n_batches);
        run_batch_scaling(profile_id, scale_length, threads_field, warmup_runs, nruns,
                          max_mem_mb, include_transfers, timing_mode,
                          batch_scale_set, n_batch_scale);
    } else {
        fprintf(stderr, "ERROR: unknown BENCH_WORKLOAD='%s' (expected throughput|batch_scaling|all)\n",
                workload);
        return 2;
    }

    ce = cudaDeviceSynchronize();
    if (ce != cudaSuccess) {
        fprintf(stderr, "ERROR: cudaDeviceSynchronize failed: %s\n", cudaGetErrorString(ce));
        return 1;
    }
    printf("\nBenchmark workload complete.\n\n");
    return 0;
}
