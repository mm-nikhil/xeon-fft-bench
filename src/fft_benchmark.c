/*
 * fft_benchmark.c
 * Intel oneMKL 3D complex FFT benchmark with workload-based execution.
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

static void random_init(MKL_Complex16 *data, int n)
{
    for (int i = 0; i < n; i++) {
        data[i].real = (double)rand() / (double)RAND_MAX;
        data[i].imag = (double)rand() / (double)RAND_MAX;
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

static void run_benchmark(const char *profile_id,
                          const char *workload,
                          const char *case_id,
                          int nx, int ny, int nz,
                          int howmany,
                          int num_threads,
                          int warmup_runs,
                          int nruns,
                          double max_mem_mb)
{
    mkl_set_num_threads(num_threads);

    MKL_LONG distance = (MKL_LONG)nx * (MKL_LONG)ny * (MKL_LONG)nz;
    MKL_LONG total = (MKL_LONG)howmany * distance;
    double mem_mb = (2.0 * (double)total * (double)sizeof(MKL_Complex16)) / (1024.0 * 1024.0);

    if (max_mem_mb > 0.0 && mem_mb > max_mem_mb) {
        printf("[skip] %-16s | Grid:%4dx%4dx%4d | Batch:%3d | Thr:%2d | Mem:%7.1f MB > limit %.1f MB\n",
               case_id, nx, ny, nz, howmany, num_threads, mem_mb, max_mem_mb);
        printf("SKIP|%s|%s|%s|%d|%d|%d|%d|%d|%.2f|memory_limit\n",
               profile_id, workload, case_id,
               nx, ny, nz, howmany, num_threads,
               mem_mb);
        fflush(stdout);
        return;
    }

    MKL_Complex16 *in = (MKL_Complex16 *)mkl_malloc((size_t)total * sizeof(MKL_Complex16), 64);
    MKL_Complex16 *out = (MKL_Complex16 *)mkl_malloc((size_t)total * sizeof(MKL_Complex16), 64);
    if (!in || !out) {
        fprintf(stderr, "ERROR: allocation failed for %dx%dx%d batch=%d (%.1f MB)\n",
                nx, ny, nz, howmany, mem_mb);
        mkl_free(in);
        mkl_free(out);
        return;
    }

    srand(42);
    random_init(in, (int)total);
    memset(out, 0, (size_t)total * sizeof(MKL_Complex16));

    MKL_LONG shape[3] = {nx, ny, nz};
    DFTI_DESCRIPTOR_HANDLE plan = NULL;
    MKL_LONG status = DftiCreateDescriptor(&plan, DFTI_DOUBLE, DFTI_COMPLEX, 3, shape);
    status |= DftiSetValue(plan, DFTI_NUMBER_OF_TRANSFORMS, howmany);
    status |= DftiSetValue(plan, DFTI_INPUT_DISTANCE, distance);
    status |= DftiSetValue(plan, DFTI_OUTPUT_DISTANCE, distance);
    status |= DftiSetValue(plan, DFTI_PLACEMENT, DFTI_NOT_INPLACE);
    status |= DftiCommitDescriptor(plan);

    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: DFTI descriptor setup failed: %ld\n", status);
        DftiFreeDescriptor(&plan);
        mkl_free(in);
        mkl_free(out);
        return;
    }

    for (int i = 0; i < warmup_runs; i++) {
        status = DftiComputeForward(plan, in, out);
        if (status != DFTI_NO_ERROR) {
            fprintf(stderr, "ERROR: warmup forward failed: %ld\n", status);
            DftiFreeDescriptor(&plan);
            mkl_free(in);
            mkl_free(out);
            return;
        }
    }

    double t0 = get_time_ms();
    for (int i = 0; i < nruns; i++) {
        status = DftiComputeForward(plan, in, out);
        if (status != DFTI_NO_ERROR) {
            fprintf(stderr, "ERROR: timed forward failed: %ld\n", status);
            DftiFreeDescriptor(&plan);
            mkl_free(in);
            mkl_free(out);
            return;
        }
    }
    double fwd_ms = (get_time_ms() - t0) / (double)nruns;

    t0 = get_time_ms();
    for (int i = 0; i < nruns; i++) {
        status = DftiComputeBackward(plan, out, in);
        if (status != DFTI_NO_ERROR) {
            fprintf(stderr, "ERROR: timed backward failed: %ld\n", status);
            DftiFreeDescriptor(&plan);
            mkl_free(in);
            mkl_free(out);
            return;
        }
    }
    double bwd_ms = (get_time_ms() - t0) / (double)nruns;

    double n_total = (double)nx * (double)ny * (double)nz;
    double flops = 5.0 * n_total * log2(n_total) * (double)howmany;
    double fwd_gflops = flops / (fwd_ms * 1.0e6);
    double bwd_gflops = flops / (bwd_ms * 1.0e6);

    printf("[run ] %-16s | Grid:%4dx%4dx%4d | Batch:%3d | Thr:%2d | "
           "Fwd:%8.3f ms %8.2f GF/s | Bwd:%8.3f ms %8.2f GF/s | Mem:%7.1f MB\n",
           case_id,
           nx, ny, nz, howmany, num_threads,
           fwd_ms, fwd_gflops,
           bwd_ms, bwd_gflops,
           mem_mb);

    printf("RESULT|%s|%s|%s|%d|%d|%d|%d|%d|%.6f|%.6f|%.6f|%.6f|%.2f\n",
           profile_id,
           workload,
           case_id,
           nx, ny, nz,
           howmany,
           num_threads,
           fwd_ms,
           fwd_gflops,
           bwd_ms,
           bwd_gflops,
           mem_mb);
    fflush(stdout);

    DftiFreeDescriptor(&plan);
    mkl_free(in);
    mkl_free(out);
}

static void run_throughput(const char *profile_id,
                           int threads,
                           int warmup_runs,
                           int nruns,
                           double max_mem_mb,
                           const int *cubes,
                           int n_cubes,
                           const int *batches,
                           int n_batches)
{
    section("WORKLOAD: throughput (grid x batch at fixed thread count)");
    printf("threads=%d\n", threads);

    for (int i = 0; i < n_cubes; i++) {
        for (int j = 0; j < n_batches; j++) {
            char case_id[64];
            snprintf(case_id, sizeof(case_id), "n%d_b%d", cubes[i], batches[j]);
            run_benchmark(profile_id,
                          "throughput",
                          case_id,
                          cubes[i], cubes[i], cubes[i],
                          batches[j],
                          threads,
                          warmup_runs,
                          nruns,
                          max_mem_mb);
        }
    }
}

static void run_thread_scaling(const char *profile_id,
                               int cube,
                               int batch,
                               int warmup_runs,
                               int nruns,
                               double max_mem_mb,
                               const int *threads,
                               int n_threads)
{
    section("WORKLOAD: thread_scaling (fixed grid/batch, vary threads)");
    printf("grid=%dx%dx%d batch=%d\n", cube, cube, cube, batch);

    for (int i = 0; i < n_threads; i++) {
        char case_id[64];
        snprintf(case_id, sizeof(case_id), "n%d_b%d_t%d", cube, batch, threads[i]);
        run_benchmark(profile_id,
                      "thread_scaling",
                      case_id,
                      cube, cube, cube,
                      batch,
                      threads[i],
                      warmup_runs,
                      nruns,
                      max_mem_mb);
    }
}

static void run_batch_scaling(const char *profile_id,
                              int cube,
                              int threads,
                              int warmup_runs,
                              int nruns,
                              double max_mem_mb,
                              const int *batches,
                              int n_batches)
{
    section("WORKLOAD: batch_scaling (fixed grid/threads, vary batch)");
    printf("grid=%dx%dx%d threads=%d\n", cube, cube, cube, threads);

    for (int i = 0; i < n_batches; i++) {
        char case_id[64];
        snprintf(case_id, sizeof(case_id), "n%d_b%d_t%d", cube, batches[i], threads);
        run_benchmark(profile_id,
                      "batch_scaling",
                      case_id,
                      cube, cube, cube,
                      batches[i],
                      threads,
                      warmup_runs,
                      nruns,
                      max_mem_mb);
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

    const char *profile_id = getenv("BENCH_PROFILE");
    if (!profile_id || !*profile_id) profile_id = "manual";

    const char *profile_desc = getenv("BENCH_PROFILE_DESC");
    if (!profile_desc || !*profile_desc) profile_desc = "manual run";

    const char *workload = getenv("BENCH_WORKLOAD");
    if (!workload || !*workload) workload = "throughput";

    int cubes[MAX_LIST];
    int batches[MAX_LIST];
    int thread_set[MAX_LIST];
    int batch_scale_set[MAX_LIST];

    int n_cubes = load_int_list("BENCH_CUBES", "32,64,128,256", cubes, MAX_LIST, 2, 8192);
    int n_batches = load_int_list("BENCH_BATCHES", "1,4", batches, MAX_LIST, 1, 1024);
    int n_thread_set = load_int_list("BENCH_THREAD_SET", "1,2,4,8,10,20", thread_set, MAX_LIST, 1, 4096);
    int n_batch_scale = load_int_list("BENCH_BATCH_SCALE_SET", "1,2,4,8,16,32", batch_scale_set, MAX_LIST, 1, 4096);

    if (n_cubes <= 0) {
        cubes[0] = 32; cubes[1] = 64; cubes[2] = 128;
        n_cubes = 3;
    }
    if (n_batches <= 0) {
        batches[0] = 1; batches[1] = 4;
        n_batches = 2;
    }
    if (n_thread_set <= 0) {
        thread_set[0] = 1; thread_set[1] = 2; thread_set[2] = 4; thread_set[3] = 8;
        n_thread_set = 4;
    }
    if (n_batch_scale <= 0) {
        batch_scale_set[0] = 1; batch_scale_set[1] = 2; batch_scale_set[2] = 4;
        n_batch_scale = 3;
    }

    int scale_cube = env_int("BENCH_SCALE_CUBE", 128, 2, 8192);
    int scale_batch = env_int("BENCH_SCALE_BATCH", 4, 1, 4096);
    int scale_threads = env_int("BENCH_SCALE_THREADS", cli_threads, 1, 4096);

    printf("\n############################################################\n");
    printf("# FFT BENCHMARK (Intel oneMKL DFTI)                        #\n");
    printf("############################################################\n");
    printf("profile_id       : %s\n", profile_id);
    printf("profile_desc     : %s\n", profile_desc);
    printf("workload         : %s\n", workload);
    printf("threads(cli)     : %d\n", cli_threads);
    printf("mkl max threads  : %d\n", max_threads);
    printf("timed runs       : %d\n", nruns);
    printf("warmup runs      : %d\n", warmup_runs);
    printf("mem cap (MB)     : %.1f\n", max_mem_mb);
    print_list("cubes", cubes, n_cubes);
    print_list("batches", batches, n_batches);
    print_list("thread_set", thread_set, n_thread_set);
    print_list("batch_scale_set", batch_scale_set, n_batch_scale);
    printf("scale_cube       : %d\n", scale_cube);
    printf("scale_batch      : %d\n", scale_batch);
    printf("scale_threads    : %d\n", scale_threads);
    printf("\n");

    if (strcmp(workload, "throughput") == 0) {
        run_throughput(profile_id,
                       cli_threads,
                       warmup_runs,
                       nruns,
                       max_mem_mb,
                       cubes,
                       n_cubes,
                       batches,
                       n_batches);
    } else if (strcmp(workload, "thread_scaling") == 0) {
        run_thread_scaling(profile_id,
                           scale_cube,
                           scale_batch,
                           warmup_runs,
                           nruns,
                           max_mem_mb,
                           thread_set,
                           n_thread_set);
    } else if (strcmp(workload, "batch_scaling") == 0) {
        run_batch_scaling(profile_id,
                          scale_cube,
                          scale_threads,
                          warmup_runs,
                          nruns,
                          max_mem_mb,
                          batch_scale_set,
                          n_batch_scale);
    } else if (strcmp(workload, "all") == 0) {
        run_throughput(profile_id,
                       cli_threads,
                       warmup_runs,
                       nruns,
                       max_mem_mb,
                       cubes,
                       n_cubes,
                       batches,
                       n_batches);

        run_thread_scaling(profile_id,
                           scale_cube,
                           scale_batch,
                           warmup_runs,
                           nruns,
                           max_mem_mb,
                           thread_set,
                           n_thread_set);

        run_batch_scaling(profile_id,
                          scale_cube,
                          scale_threads,
                          warmup_runs,
                          nruns,
                          max_mem_mb,
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
