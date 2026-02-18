/*
 * fft_benchmark.c
 * FFT Benchmark using Intel MKL DFT
 * Random initialized data, 3D complex-to-complex FFT
 * Tests: CPU baseline, AVX-512, multithreaded
 *
 * Compile options are handled by the run script.
 */

#define _POSIX_C_SOURCE 200809L

#include <mkl_dfti.h>
#include <mkl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

/* ── Timer ───────────────────────────────────────────────── */
static double get_time_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1.0e6;
}

/* ── Random init ─────────────────────────────────────────── */
static void random_init(MKL_Complex16 *data, int n)
{
    for (int i = 0; i < n; i++) {
        data[i].real = (double)rand() / RAND_MAX;
        data[i].imag = (double)rand() / RAND_MAX;
    }
}

/* ── Environment integer helper ──────────────────────────── */
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

/* ── Single benchmark run ────────────────────────────────── */
static void run_benchmark(int nx, int ny, int nz,
                          int howmany, int num_threads,
                          int warmup_runs, int nruns, const char *label)
{
    mkl_set_num_threads(num_threads);

    MKL_LONG ngrid[3]  = { nx, ny, nz };
    MKL_LONG distance  = (MKL_LONG)nx * ny * nz;
    int      total     = (int)(howmany * distance);

    /* 64-byte aligned alloc (required for AVX-512 efficiency) */
    MKL_Complex16 *in  = (MKL_Complex16*)mkl_malloc(
                             total * sizeof(MKL_Complex16), 64);
    MKL_Complex16 *out = (MKL_Complex16*)mkl_malloc(
                             total * sizeof(MKL_Complex16), 64);

    if (!in || !out) {
        fprintf(stderr, "ERROR: malloc failed for %dx%dx%d batch=%d\n",
                nx, ny, nz, howmany);
        mkl_free(in); mkl_free(out);
        return;
    }

    /* Random data — values don't affect timing */
    srand(42);
    random_init(in, total);
    memset(out, 0, total * sizeof(MKL_Complex16));

    /* ── Descriptor setup ── */
    DFTI_DESCRIPTOR_HANDLE plan = NULL;
    MKL_LONG status;

    status = DftiCreateDescriptor(&plan,
                                  DFTI_DOUBLE,
                                  DFTI_COMPLEX,
                                  3, ngrid);
    status |= DftiSetValue(plan, DFTI_NUMBER_OF_TRANSFORMS, howmany);
    status |= DftiSetValue(plan, DFTI_INPUT_DISTANCE,  distance);
    status |= DftiSetValue(plan, DFTI_OUTPUT_DISTANCE, distance);
    status |= DftiSetValue(plan, DFTI_PLACEMENT, DFTI_NOT_INPLACE);
    status |= DftiCommitDescriptor(plan);

    if (status != DFTI_NO_ERROR) {
        fprintf(stderr, "ERROR: MKL descriptor setup failed: %ld\n", status);
        DftiFreeDescriptor(&plan);
        mkl_free(in); mkl_free(out);
        return;
    }

    /* ── Warmup (5 runs, not timed) ──
     * Critical on Skylake-X: lets AVX-512 frequency settle
     * before we start the clock.                            */
    for (int w = 0; w < warmup_runs; w++) {
        status = DftiComputeForward(plan, in, out);
        if (status != DFTI_NO_ERROR) {
            fprintf(stderr, "ERROR: warmup forward failed: %ld\n", status);
            DftiFreeDescriptor(&plan);
            mkl_free(in);
            mkl_free(out);
            return;
        }
    }

    /* ── Timed forward FFT runs ── */
    double start = get_time_ms();
    for (int r = 0; r < nruns; r++) {
        status = DftiComputeForward(plan, in, out);
        if (status != DFTI_NO_ERROR) {
            fprintf(stderr, "ERROR: timed forward failed: %ld\n", status);
            DftiFreeDescriptor(&plan);
            mkl_free(in);
            mkl_free(out);
            return;
        }
    }
    double elapsed_fwd = (get_time_ms() - start) / nruns;

    /* ── Timed inverse FFT runs ── */
    start = get_time_ms();
    for (int r = 0; r < nruns; r++) {
        status = DftiComputeBackward(plan, out, in);
        if (status != DFTI_NO_ERROR) {
            fprintf(stderr, "ERROR: timed backward failed: %ld\n", status);
            DftiFreeDescriptor(&plan);
            mkl_free(in);
            mkl_free(out);
            return;
        }
    }
    double elapsed_bwd = (get_time_ms() - start) / nruns;

    /* ── GFLOPS: 5 * N * log2(N) per transform (Cooley-Tukey) ── */
    double N_total = (double)(nx * ny * nz);
    double flops   = 5.0 * N_total * log2(N_total) * howmany;
    double gf_fwd  = flops / (elapsed_fwd * 1.0e6);
    double gf_bwd  = flops / (elapsed_bwd * 1.0e6);

    /* Memory footprint */
    double mem_mb  = (2.0 * total * sizeof(MKL_Complex16)) / (1024.0 * 1024.0);

    printf("%-22s | Grid: %4dx%4dx%4d | Batch:%3d | Thr:%2d | "
           "Fwd: %8.3f ms  %7.2f GFLOPS | "
           "Bwd: %8.3f ms  %7.2f GFLOPS | "
           "Mem: %6.1f MB\n",
           label,
           nx, ny, nz, howmany, num_threads,
           elapsed_fwd, gf_fwd,
           elapsed_bwd, gf_bwd,
           mem_mb);
    fflush(stdout);

    DftiFreeDescriptor(&plan);
    mkl_free(in);
    mkl_free(out);
}

/* ── Print section header ────────────────────────────────── */
static void section(const char *title)
{
    printf("\n");
    printf("================================================================"
           "========================\n");
    printf("  %s\n", title);
    printf("================================================================"
           "========================\n");
}

/* ─────────────────────────────────────────────────────────── */
int main(int argc, char *argv[])
{
    /* Allow thread count override from command line:
     *   ./fft_benchmark 10
     * defaults to 1 if not given (control via env vars from run script) */
    int cli_threads = (argc > 1) ? atoi(argv[1]) : 1;
    int max_threads = mkl_get_max_threads();
    int NRUNS       = env_int("BENCH_NRUNS", 20, 1, 1000000);
    int WARMUP_RUNS = env_int("BENCH_WARMUP", 5, 0, 1000000);

    /* ── Header ── */
    printf("\n");
    printf("########################################################\n");
    printf("#         FFT BENCHMARK — Intel MKL DFT                #\n");
    printf("#         Random Initialized 3D Complex FFT             #\n");
    printf("########################################################\n");
    printf("MKL max threads available : %d\n", max_threads);
    printf("Threads requested (cli)   : %d\n", cli_threads);
    printf("Timed runs per config     : %d\n", NRUNS);
    printf("Warmup runs               : %d (untimed, stabilize AVX freq)\n",
           WARMUP_RUNS);
    printf("\n");
    printf("Column guide:\n");
    printf("  Fwd = forward FFT (time + GFLOPS)\n");
    printf("  Bwd = inverse FFT (time + GFLOPS)\n");
    printf("  Mem = total memory used by in+out buffers\n");
    printf("\n");

    /* ── Cache reference for W-2155 ── */
    printf("Cache reference (W-2155):\n");
    printf("  L1d  32KB  → fits 1D FFT N < 2K complex doubles\n");
    printf("  L2    1MB  → fits 3D FFT up to ~40^3\n");
    printf("  L3   14MB  → fits 3D FFT up to ~96^3  (64^3 = 4MB  ✓)\n");
    printf("  DRAM       → 128^3 = 32MB  (spills L3)   256^3 = 256MB\n");

    /* ════════════════════════════════════════════════════════
     * SECTION 1: CPU-Only baseline  (1 thread, no AVX forced)
     * Compiler flag: -O2  (no -march / -xHost / -xAVX)
     * ════════════════════════════════════════════════════════ */
    section("SCENARIO 1 — CPU ONLY (1 thread, scalar baseline)");
    printf("  NOTE: Set by compile flag -O2  — no explicit AVX enabled\n\n");

    run_benchmark( 64,  64,  64,  1, 1, WARMUP_RUNS, NRUNS, "64^3 batch=1");
    run_benchmark( 64,  64,  64,  4, 1, WARMUP_RUNS, NRUNS, "64^3 batch=4");
    run_benchmark(128, 128, 128,  1, 1, WARMUP_RUNS, NRUNS, "128^3 batch=1");
    run_benchmark(128, 128, 128,  4, 1, WARMUP_RUNS, NRUNS, "128^3 batch=4");
    run_benchmark(256, 256, 256,  1, 1, WARMUP_RUNS, NRUNS, "256^3 batch=1");

    /* ════════════════════════════════════════════════════════
     * SECTION 2: CPU + AVX-512  (still 1 thread)
     * Compiler flag: -O3 -xCORE-AVX512
     * MKL will automatically use AVX-512 kernels
     * ════════════════════════════════════════════════════════ */
    section("SCENARIO 2 — CPU + AVX-512 (1 thread, vectorized)");
    printf("  NOTE: Effective only when compiled with -xCORE-AVX512\n");
    printf("        MKL selects AVX-512 kernel automatically\n\n");

    run_benchmark( 64,  64,  64,  1, 1, WARMUP_RUNS, NRUNS, "64^3 batch=1");
    run_benchmark( 64,  64,  64,  4, 1, WARMUP_RUNS, NRUNS, "64^3 batch=4");
    run_benchmark(128, 128, 128,  1, 1, WARMUP_RUNS, NRUNS, "128^3 batch=1");
    run_benchmark(128, 128, 128,  4, 1, WARMUP_RUNS, NRUNS, "128^3 batch=4");
    run_benchmark(256, 256, 256,  1, 1, WARMUP_RUNS, NRUNS, "256^3 batch=1");

    /* ════════════════════════════════════════════════════════
     * SECTION 3: AVX-512 + multithreaded
     * Uses thread count passed on command line
     * ════════════════════════════════════════════════════════ */
    section("SCENARIO 3 — AVX-512 + Multithreaded");
    printf("  Threads: %d  (override with: ./fft_benchmark <N>)\n\n",
           cli_threads);

    run_benchmark( 64,  64,  64,  1,  cli_threads, WARMUP_RUNS, NRUNS, "64^3 batch=1");
    run_benchmark( 64,  64,  64,  4,  cli_threads, WARMUP_RUNS, NRUNS, "64^3 batch=4");
    run_benchmark( 64,  64,  64, 16,  cli_threads, WARMUP_RUNS, NRUNS, "64^3 batch=16");
    run_benchmark(128, 128, 128,  1,  cli_threads, WARMUP_RUNS, NRUNS, "128^3 batch=1");
    run_benchmark(128, 128, 128,  4,  cli_threads, WARMUP_RUNS, NRUNS, "128^3 batch=4");
    run_benchmark(128, 128, 128, 16,  cli_threads, WARMUP_RUNS, NRUNS, "128^3 batch=16");
    run_benchmark(256, 256, 256,  1,  cli_threads, WARMUP_RUNS, NRUNS, "256^3 batch=1");
    run_benchmark(256, 256, 256,  4,  cli_threads, WARMUP_RUNS, NRUNS, "256^3 batch=4");

    /* ════════════════════════════════════════════════════════
     * SECTION 4: Thread scaling sweep
     * Same problem, increasing threads: 1 2 4 8 10 20
     * ════════════════════════════════════════════════════════ */
    section("SCENARIO 4 — Thread Scaling Sweep (128^3 batch=4)");
    printf("  Shows how FFT scales across your 10 physical cores\n\n");

    int thread_counts[] = { 1, 2, 4, 8, 10, 20 };
    int ntc = sizeof(thread_counts) / sizeof(thread_counts[0]);
    char label[64];
    for (int t = 0; t < ntc; t++) {
        snprintf(label, sizeof(label), "128^3 thr=%d", thread_counts[t]);
        run_benchmark(128, 128, 128, 4, thread_counts[t], WARMUP_RUNS, NRUNS, label);
    }

    /* ════════════════════════════════════════════════════════
     * SECTION 5: Batch scaling sweep
     * Same problem, increasing batch size
     * (shows twiddle factor reuse benefit)
     * ════════════════════════════════════════════════════════ */
    section("SCENARIO 5 — Batch Scaling Sweep (128^3, max threads)");
    printf("  Shows benefit of batched FFT vs repeated single calls\n\n");

    int batch_sizes[] = { 1, 2, 4, 8, 16, 32 };
    int nbs = sizeof(batch_sizes) / sizeof(batch_sizes[0]);
    for (int b = 0; b < nbs; b++) {
        snprintf(label, sizeof(label), "128^3 batch=%d", batch_sizes[b]);
        run_benchmark(128, 128, 128, batch_sizes[b], cli_threads, WARMUP_RUNS, NRUNS, label);
    }

    printf("\n");
    printf("########################################################\n");
    printf("#                  BENCHMARK COMPLETE                  #\n");
    printf("########################################################\n\n");

    return 0;
}
