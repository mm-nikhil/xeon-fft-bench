# Deep Walkthrough: `fft_benchmark.c` and `run_fft_benchmarks.sh`

This document is a thorough, opinionated explanation of every part of this benchmark. It covers what each line of code does, what the inputs and outputs mean, how threads work, what the scenarios actually test, where the benchmark is solid, and where it has real problems.

---

## 1. Hardware Context You Must Keep in Mind

Everything in this benchmark is designed around this machine:

```
CPU    : Intel Xeon W-2155 @ 3.30 GHz (Skylake-X microarchitecture)
Cores  : 10 physical cores / 20 logical threads (Hyper-Threading, 2 per core)
Socket : 1 socket, 1 NUMA node
Cache  : L1d 32 KB per core | L2 1 MB per core | L3 14 MB shared (all 10 cores)
AVX    : AVX, AVX2, AVX-512F, AVX-512DQ, AVX-512BW, AVX-512CD, AVX-512VL
DRAM   : (external to chip, shared bandwidth)
```

The hostname in the logs is `amdtoolsserver.morphingmachines`. Despite the name, the machine runs an Intel Xeon. The hostname is just a label.

**Critical Skylake-X quirk: AVX-512 frequency throttling.**
When the processor executes sustained AVX-512 instructions (512-bit wide FMA ops), it drops its clock from 3.3 GHz to roughly 2.5 GHz (the "AVX-512 license" frequency). This happens automatically to stay within thermal design power. The result: AVX-512 throughput is higher per clock (operates on 8 doubles at once vs 4 for AVX2), but the clock is slower. The net benefit depends on whether the workload is compute-bound or memory-bound. This is why the warmup runs exist — to force the CPU into the throttled frequency *before* measurement starts, so your timed numbers reflect the steady-state AVX-512 speed.

**Cache working set for the grid sizes used:**

| Grid size | Points (N) | Memory per transform (complex double, 16 B) | Fits in |
|-----------|-----------|----------------------------------------------|---------|
| 64^3      | 262,144   | 4 MB                                         | L3 (14 MB) ✓ |
| 128^3     | 2,097,152 | 32 MB                                        | DRAM (spills L3) |
| 256^3     | 16,777,216| 256 MB                                       | DRAM (deeply) |

This matters a lot: 64^3 is compute-bound (data fits in L3), 128^3 and 256^3 are memory-bound.

---

## 2. The Two Levels of "Scenario": The Most Confusing Thing in This Project

This benchmark has **two separate, overlapping uses of the word "Scenario"**, and conflating them will make every log unreadable.

### Level 1: Shell Script Outer Scenarios (4 total)

These are invocations of the compiled binary with different ISA instructions and thread counts. The shell controls these.

| Shell Scenario | Binary         | MKL_ENABLE_INSTRUCTIONS | Threads |
|----------------|----------------|--------------------------|---------|
| Scenario 1     | `fft_cpu_only` | `SSE4_2`                 | 1       |
| Scenario 2     | `fft_avx512`   | `AVX512`                 | 1       |
| Scenario 3     | `fft_avx512`   | `AVX512`                 | 10 (physical) |
| Scenario 3b    | `fft_avx512`   | `AVX512`                 | 20 (logical)  |

### Level 2: C Program Inner Sections (5 total, run inside every outer scenario)

These are hard-coded sections *inside* `fft_benchmark.c` that run in sequence every time the binary is called.

| C Section | What it varies | Fixed parameters |
|-----------|----------------|-----------------|
| SCENARIO 1 | Grid size only | 1 thread |
| SCENARIO 2 | Grid size only | 1 thread |
| SCENARIO 3 | Grid + batch   | cli_threads |
| SCENARIO 4 | Thread count   | 128^3, batch=4 |
| SCENARIO 5 | Batch size     | 128^3, cli_threads |

**The consequence**: every outer run produces output for all 5 inner sections. A full benchmark run produces 4 × 5 = 20 section outputs in the log, all with the same labels. This makes logs long and difficult to navigate without carefully anchoring your position by the outer `RUNNING: Scenario ...` header.

---

## 3. What the Inputs Mean

### 3.1 Grid size: what `64^3`, `128^3`, `256^3` mean

The FFT is **3-dimensional**. The grid `nx × ny × nz` describes the shape of a 3D volume.

`64^3` means `nx=64, ny=64, nz=64`. The total number of complex data points in one transform is:

```
N = nx × ny × nz = 64 × 64 × 64 = 262,144 points
```

Each point is a `MKL_Complex16` — a struct with two `double` values (real and imaginary), totalling 16 bytes per point.

So one 64^3 transform needs: `262,144 × 16 = 4,194,304 bytes = 4 MB`.

This benchmark uses **out-of-place** transforms, meaning input and output are separate buffers. So the full memory for one 64^3 transform is `2 × 4 MB = 8 MB`.

For 128^3:
```
N = 128 × 128 × 128 = 2,097,152 points
Memory per buffer = 2,097,152 × 16 = 32 MB
Two buffers = 64 MB
```

For 256^3:
```
N = 256 × 256 × 256 = 16,777,216 points
Memory per buffer = 256 MB
Two buffers = 512 MB
```

These numbers appear directly in the log's "Mem:" column.

### 3.2 Batch size: what `batch=4`, `batch=16` etc. mean

`batch` (called `howmany` in the C code) means: **how many independent 3D FFTs are computed in a single DFTI call**.

When you set `DFTI_NUMBER_OF_TRANSFORMS = 4`, you are telling MKL: "I have 4 completely separate 3D volumes stacked in memory. Transform all 4 in one call."

The memory layout is contiguous: transforms are placed back-to-back with no padding. The `distance` variable in the C code defines how far apart consecutive transforms are in memory (in elements):

```c
MKL_LONG distance = (MKL_LONG)nx * ny * nz;  // one transform's worth of elements
```

So for 128^3 batch=4:
- Total elements: `2,097,152 × 4 = 8,388,608`
- Total memory (in + out): `8,388,608 × 2 × 16 bytes = 256 MB`

This matches the log output exactly (`Mem: 256.0 MB`).

**Why batch matters**: MKL can compute twiddle factors (sine/cosine tables used in the FFT butterfly computation) once and reuse them across all transforms in the batch. For sizes that fit in L3 cache, this is a meaningful speedup. For sizes that spill to DRAM (128^3 and up), the benefit is hidden by memory bandwidth saturation.

### 3.3 What `32x32` would mean (not currently used)

If the benchmark had a `32^3` grid, that would be:
```
N = 32,768 points
Memory per buffer = 512 KB
Two buffers = 1 MB (fits in L2!)
```
At this size, FFT is essentially fully L2-cache resident. Twiddle factor reuse from batching would be clearly visible, and per-GFLOPS numbers would be much higher. The current benchmark skips this size, which is a gap (discussed in section 10).

---

## 4. `fft_benchmark.c`: Line-by-Line

### 4.1 Headers and defines

```c
#define _POSIX_C_SOURCE 200809L
```
Enables POSIX 2008 API features, specifically needed for `clock_gettime` with `CLOCK_MONOTONIC`. Without this define, `clock_gettime` might not be declared on some POSIX-strict build configurations.

```c
#include <mkl_dfti.h>   // MKL DFT descriptor API
#include <mkl.h>        // mkl_set_num_threads, mkl_malloc, mkl_free, mkl_get_max_threads
```
MKL's DFTI (Discrete Fourier Transform Interface) is the main FFT API used here. `mkl.h` provides thread control and memory allocation functions.

### 4.2 Timer function

```c
static double get_time_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1.0e6;
}
```

`CLOCK_MONOTONIC` is a timer that never goes backwards and is unaffected by system time changes. It measures wall-clock time from some arbitrary starting point. The return value is milliseconds as a double. This is the right choice for timing parallel code because it measures real elapsed time, not CPU time.

Important: this measures **wall-clock (real) time**, not CPU time. For multithreaded runs, wall-clock time reflects the actual throughput improvement from parallelism.

### 4.3 Random initialization

```c
static void random_init(MKL_Complex16 *data, int n)
{
    for (int i = 0; i < n; i++) {
        data[i].real = (double)rand() / RAND_MAX;
        data[i].imag = (double)rand() / RAND_MAX;
    }
}
```

FFT computation time is independent of input values — it performs the same butterfly operations regardless of what numbers are in the array. So random initialization is correct for timing purposes. The seed is fixed at 42 (`srand(42)`), making results deterministic across runs.

`MKL_Complex16` is a struct of two doubles: `{ double real; double imag; }`. It is MKL's type for double-precision complex numbers.

### 4.4 Environment integer helper

```c
static int env_int(const char *name, int fallback, int min_v, int max_v)
```

This reads an integer from an environment variable with bounds checking. It is used to read `BENCH_NRUNS` and `BENCH_WARMUP` from the shell environment (set by `run_fft_benchmarks.sh`). If the variable is missing or out of range, it falls back to the default.

### 4.5 The core benchmark function: `run_benchmark`

This is the heart of the entire file. Every data point in the log comes from one call to this function.

```c
static void run_benchmark(int nx, int ny, int nz,
                          int howmany, int num_threads,
                          int warmup_runs, int nruns, const char *label)
```

Parameters:
- `nx, ny, nz`: 3D grid dimensions
- `howmany`: batch size (number of simultaneous transforms)
- `num_threads`: how many MKL threads to use
- `warmup_runs`: number of untimed warmup iterations
- `nruns`: number of timed iterations to average
- `label`: string printed in the output line

**Step 1: Set thread count**
```c
mkl_set_num_threads(num_threads);
```
This tells MKL how many threads to use for this specific call. It overrides `OMP_NUM_THREADS` and `MKL_NUM_THREADS` environment variables from within the process. This is how the inner C scenarios can test different thread counts within a single run.

**Step 2: Allocate aligned memory**
```c
MKL_Complex16 *in  = (MKL_Complex16*)mkl_malloc(total * sizeof(MKL_Complex16), 64);
MKL_Complex16 *out = (MKL_Complex16*)mkl_malloc(total * sizeof(MKL_Complex16), 64);
```
`mkl_malloc(size, alignment)` guarantees 64-byte alignment. AVX-512 registers are 512 bits = 64 bytes wide. A misaligned load across a 64-byte cache line boundary forces two cache-line fetches instead of one. With aligned data, 8 complex doubles fit exactly in one AVX-512 register and load in one operation.

Using `malloc()` instead of `mkl_malloc()` would not guarantee this alignment and could cause a measurable performance penalty on AVX-512 paths.

**Step 3: Initialize data**
```c
srand(42);
random_init(in, total);
memset(out, 0, total * sizeof(MKL_Complex16));
```
Input filled with deterministic random values. Output zeroed (not strictly necessary, but avoids reading uninitialized memory). The `srand(42)` reset here means every benchmark configuration starts from the same initial data.

**Step 4: Create and configure the DFTI descriptor**
```c
status = DftiCreateDescriptor(&plan, DFTI_DOUBLE, DFTI_COMPLEX, 3, ngrid);
status |= DftiSetValue(plan, DFTI_NUMBER_OF_TRANSFORMS, howmany);
status |= DftiSetValue(plan, DFTI_INPUT_DISTANCE,  distance);
status |= DftiSetValue(plan, DFTI_OUTPUT_DISTANCE, distance);
status |= DftiSetValue(plan, DFTI_PLACEMENT, DFTI_NOT_INPLACE);
status |= DftiCommitDescriptor(plan);
```

- `DFTI_DOUBLE` — double-precision (64-bit) floating point
- `DFTI_COMPLEX` — input and output are complex
- `3` — three-dimensional transform
- `ngrid = {nx, ny, nz}` — dimensions
- `DFTI_NUMBER_OF_TRANSFORMS = howmany` — enables batched operation
- `DFTI_INPUT_DISTANCE` / `DFTI_OUTPUT_DISTANCE` — offset in *elements* between consecutive transforms in the batch. Set to `nx*ny*nz`, meaning transforms are packed contiguously.
- `DFTI_NOT_INPLACE` — output goes to a separate buffer (out-of-place)

`DftiCommitDescriptor` is where MKL does its internal planning: it analyzes the transform shape, selects the optimal algorithm (Cooley-Tukey for powers of 2), pre-computes twiddle factor tables, and prepares the execution plan. This is the expensive setup step — it is done once per configuration, not once per timed run. Its cost is amortized across `warmup_runs + nruns` executions.

**Step 5: Warmup runs (untimed)**
```c
for (int w = 0; w < warmup_runs; w++) {
    status = DftiComputeForward(plan, in, out);
}
```
On Skylake-X, the first time AVX-512 instructions execute after a period of idle, the CPU needs a short ramp-up before the clock frequency drops to the sustained AVX-512 rate. Without warmup, the first timed run would happen at the full 3.3 GHz boost frequency, making it appear faster than the sustained rate. The warmup forces the frequency to settle so all timed runs are at the same, stable operating point.

Default is 5 warmup runs. For large transforms (128^3 at ~100ms each), 5 runs = 500ms of warmup — sufficient. For tiny transforms (64^3 at ~1ms), 5 runs = 5ms — probably not enough for frequency to fully stabilize. This is a known limitation discussed in section 10.

**Step 6: Timed forward FFT**
```c
double start = get_time_ms();
for (int r = 0; r < nruns; r++) {
    status = DftiComputeForward(plan, in, out);
}
double elapsed_fwd = (get_time_ms() - start) / nruns;
```
`DftiComputeForward` computes the forward DFT: `out = FFT(in)`.

The time measurement wraps the entire loop, then divides by `nruns`. This gives the average time per transform across all runs. Default is 20 timed runs.

Note: the data in `out` is updated each iteration and `in` is not updated. So each forward run computes `FFT(same_input) → out`. The output is overwritten but not reset between runs. For timing purposes this is fine, but for correctness testing it means you cannot verify round-trip identity.

**Step 7: Timed backward (inverse) FFT**
```c
double start = get_time_ms();
for (int r = 0; r < nruns; r++) {
    status = DftiComputeBackward(plan, out, in);
}
double elapsed_bwd = (get_time_ms() - start) / nruns;
```
`DftiComputeBackward` computes the inverse DFT: `in = IFFT(out)`. MKL's convention for "backward" is the unnormalized inverse (no `1/N` scaling). The result is `N × original_input`, not `original_input`. This benchmark does not correct for this, which is fine for timing but means you cannot check correctness without applying the 1/N normalization.

**Step 8: GFLOPS computation**
```c
double N_total = (double)(nx * ny * nz);
double flops   = 5.0 * N_total * log2(N_total) * howmany;
double gf_fwd  = flops / (elapsed_fwd * 1.0e6);
double gf_bwd  = flops / (elapsed_bwd * 1.0e6);
```

The formula `5 * N * log2(N)` is the **standard theoretical FLOP count for a complex-to-complex FFT** using the Cooley-Tukey algorithm. Each butterfly requires 4 real multiplications and 2 real additions for a total of 6 operations per butterfly. With N/2 log2(N) butterflies, and counting multiplications as 2 flops (mul+add fused), the standard approximation is `5 * N * log2(N)`.

The factor `* howmany` scales for the batch.

`elapsed_fwd * 1.0e6` converts milliseconds to microseconds... wait, no. Let's be precise:
- `elapsed_fwd` is in milliseconds
- `flops / (elapsed_fwd * 1e6)` = flops / (ms × 10^6) = flops / (10^-3 s × 10^6) = flops / (10^3 s × ... )

Actually: `1 ms = 10^-3 s`. So `elapsed_fwd ms = elapsed_fwd × 10^-3 s`. Then:
```
flops / (elapsed_fwd × 10^-3 s) = flops per second
flops / (elapsed_fwd × 10^-3) / 10^9 = GFLOPS
```
The code: `flops / (elapsed_fwd * 1.0e6)`.
- `elapsed_fwd * 1e6`: if elapsed is 10 ms, this is 10 × 10^6 = 10^7
- `flops / 10^7` where flops is in units of flops
- Result is in units of gigaflops only if `1e6 = 1e9 / 1e3 = 1e9 ms/s`

Let me verify the units: `GFLOPS = flops / (time_ms × 10^6)`. We want GFLOPS = flops/s / 10^9.
- `flops/s = flops / (time_ms × 10^-3)`
- `GFLOPS = flops / (time_ms × 10^-3) / 10^9 = flops / (time_ms × 10^6)` ✓

The formula is correct. GFLOPS numbers in the logs are valid.

Important caveat: this is a **theoretical** FLOP count based on the algorithmic operation count. It does not account for memory access, which can dominate performance at large sizes. When two configurations show different GFLOPS, the difference could be due to compute efficiency OR memory behavior. The GFLOPS number is useful for comparisons within this project but should not be compared against hardware peak FLOP rates without understanding these limits.

**Step 9: Output line**
```c
printf("%-22s | Grid: %4dx%4dx%4d | Batch:%3d | Thr:%2d | "
       "Fwd: %8.3f ms  %7.2f GFLOPS | "
       "Bwd: %8.3f ms  %7.2f GFLOPS | "
       "Mem: %6.1f MB\n", ...);
```

Every data line you see in the log follows this format. The 22-character left-justified label field is why labels like `"64^3 batch=1"` and `"128^3 thr=10"` align in columns.

**Step 10: Cleanup**
```c
DftiFreeDescriptor(&plan);
mkl_free(in);
mkl_free(out);
```
Releases MKL resources. Every `run_benchmark` call is fully self-contained: allocate, plan, time, free. There is no reuse of plans across calls, even when the same configuration repeats across sections. This means repeated configurations (e.g., `128^3 batch=4 thr=1` appears in SCENARIO 1, 2, 3, and 4) each re-plan from scratch. For a timing benchmark this is fine; it would matter if you were optimizing plan creation overhead.

### 4.6 `main`: Configuration and section dispatch

```c
int cli_threads = (argc > 1) ? atoi(argv[1]) : 1;
int max_threads = mkl_get_max_threads();
int NRUNS       = env_int("BENCH_NRUNS", 20, 1, 1000000);
int WARMUP_RUNS = env_int("BENCH_WARMUP", 5, 0, 1000000);
```

`cli_threads` is the thread count passed as a command-line argument. The shell script passes the thread count here: `./fft_avx512 10` for 10-thread runs. This value propagates to SCENARIO 3 and SCENARIO 5.

`max_threads` is MKL's view of how many threads are available (based on `OMP_NUM_THREADS` / `MKL_NUM_THREADS` at process start). The log shows `MKL max threads available: 1` for outer Scenario 1 (because the shell set `OMP_NUM_THREADS=1` before launching) and `MKL max threads available: 10` for outer Scenario 3.

The cache reference printout in `main` is informational only — it has no effect on the benchmark behavior.

---

## 5. `run_fft_benchmarks.sh`: Phase by Phase

### 5.1 Logging setup

```bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="./fft_logs"
mkdir -p "$LOGDIR"
LOGFILE="${LOGDIR}/fft_benchmark_${TIMESTAMP}.log"
exec > >(tee -a "$LOGFILE") 2>&1
```

`exec > >(tee -a "$LOGFILE") 2>&1` redirects both stdout and stderr of the entire script process through `tee`. This means every subsequent `echo` and every line of output from compiled binaries goes simultaneously to the terminal and the log file. The log persists after the run is complete.

### 5.2 Configurable defaults

```bash
NTHREADS_PHYSICAL="${NTHREADS_PHYSICAL:-10}"
NTHREADS_LOGICAL="${NTHREADS_LOGICAL:-20}"
BASELINE_ISA="${BASELINE_ISA:-SSE4_2}"
AVX_ISA="${AVX_ISA:-AVX512}"
BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"
```

The `${VAR:-default}` syntax uses the environment variable if set, otherwise the default. This is how you can override parameters without editing the script:
```bash
BENCH_NRUNS=5 BENCH_WARMUP=2 ./run_fft_benchmarks.sh
```

### 5.3 Intel oneAPI / MKL sourcing

The script tries three approaches to find MKL:
1. Source `/opt/intel/oneapi/setvars.sh` (standard oneAPI install)
2. Source `/opt/intel/mkl/bin/mklvars.sh` (older MKL standalone)
3. Use `module load` (HPC cluster environment)

Then `detect_mklroot()` searches four locations for `mkl_dfti.h`. The machine actually uses the pip-installed MKL at `~/.local`, which is the fourth fallback location.

### 5.4 MKL library linking

The script detects whether the MKL runtime library is named `libmkl_rt.so` or `libmkl_rt.so.2` (a versioned symlink). The linking mode uses `mkl_rt` — the **runtime dispatch library**. This single library contains code for multiple ISA paths and selects the right one at program startup based on `MKL_ENABLE_INSTRUCTIONS`. This is the key mechanism enabling the ISA comparison.

### 5.5 Compiler selection and compile flags

```bash
if [ "${USE_ICX}" -eq 1 ]; then
    FLAGS_BASE="-O2 -std=c99"
    FLAGS_AVX="-O3 -xCORE-AVX512 -std=c99"
else
    FLAGS_BASE="-O2 -std=c99"
    FLAGS_AVX="-O3 -mavx512f -mavx512dq -mavx512bw -mavx512vl -std=c99"
fi
```

Two binaries are compiled:

**`fft_cpu_only` (FLAGS_BASE)**: Compiled with `-O2`, no explicit vectorization flags. The host code (glue around MKL calls) will not use AVX-512 instructions. MKL itself is a pre-compiled library; compile flags do not affect which MKL kernel runs. Runtime ISA of MKL is controlled by `MKL_ENABLE_INSTRUCTIONS`.

**`fft_avx512` (FLAGS_AVX)**: Compiled with `-O3` and explicit AVX-512 flags. The host code can use AVX-512 for any operations outside of MKL (e.g., the random initialization loop). In practice, the initialization is not in the timed section, so this has no effect on benchmark results. The `MKL_ENABLE_INSTRUCTIONS` env var still controls MKL's kernels.

**This reveals a key issue**: the compile flags are largely irrelevant to MKL performance. Both binaries call MKL through the runtime dispatch library, and the ISA used is determined entirely by `MKL_ENABLE_INSTRUCTIONS` set by the shell. The difference between the two binaries for FFT performance is almost entirely the `MKL_ENABLE_INSTRUCTIONS` value, not the compile flags.

### 5.6 Runtime environment variables

```bash
COMMON_ENVS=(
    "KMP_AFFINITY=scatter,granularity=fine"
    "KMP_BLOCKTIME=0"
    "MKL_DYNAMIC=FALSE"
)
```

**`KMP_AFFINITY=scatter,granularity=fine`**: Controls how MKL/OpenMP threads are pinned to physical resources.
- `scatter`: distributes threads across physical cores first, then uses hyperthreads. For 4 threads, you get one thread on core 0, one on core 1, one on core 2, one on core 3 — not two threads on core 0 and two on core 1.
- `granularity=fine`: pins at the hardware thread (logical processor) level rather than the core or socket level.

This is the recommended setting from Intel's MKL FFT application notes. It prevents two threads from fighting over the same physical core's L1/L2 cache in the compute-intensive FFT phase.

**`KMP_BLOCKTIME=0`**: After a parallel region completes, OpenMP threads normally spin-wait (block) for a short time before returning to the OS. `KMP_BLOCKTIME=0` tells them to return immediately. For a benchmark with many consecutive parallel calls this reduces overhead.

**`MKL_DYNAMIC=FALSE`**: Prevents MKL from dynamically adjusting its thread count. Without this, MKL might use fewer threads than requested based on heuristics. Setting it to FALSE means MKL uses exactly the thread count you specified.

### 5.7 `run_case` function

```bash
run_case() {
    export OMP_NUM_THREADS="${threads}"
    export MKL_NUM_THREADS="${threads}"
    export MKL_ENABLE_INSTRUCTIONS="${isa}"
    time "./${bin}" "${threads}"
}
```

Both `OMP_NUM_THREADS` and `MKL_NUM_THREADS` are set. MKL reads `MKL_NUM_THREADS` preferentially but also respects `OMP_NUM_THREADS` as a fallback. Setting both ensures consistency. The thread count is also passed as `argv[1]` to the binary because `mkl_set_num_threads()` in the C code takes precedence over environment variables for each `run_benchmark` call.

`MKL_ENABLE_INSTRUCTIONS` is the key ISA switch. For Scenario 1 it is `SSE4_2` (forces MKL to use its SSE4.2 code path), for all others it is `AVX512`.

The `time` command wraps the binary execution and prints wall-clock, user, and system time for the entire run. User time being greater than wall time in the logs (e.g., `user 4m23s, real 3m52s` for outer Scenario 1) confirms multi-core usage even within Scenario 4's thread sweep.

### 5.8 MKL_VERBOSE verification

After the main runs, the script compiles and runs a minimal FFT with `MKL_VERBOSE=1`. This causes MKL to print a line like:

```
MKL_VERBOSE oneMKL 2025 Update 3 ... Intel(R) AVX-512 ... intel_thread
MKL_VERBOSE FFT(dcfi64x64x64,...) 3.61ms CNR:OFF Dyn:0 FastMM:1 TID:0 NThr:1
```

The first line confirms: MKL version, architecture, and that AVX-512 is enabled. `dcfi` in the second line means "double complex forward in-place". This is proof that the AVX-512 code path is actually active at runtime.

### 5.9 Summary extraction with `awk`

```bash
extract_fwd_gflops() {
    awk -v block="$block" -v thr="$thr" '
        $0 ~ ("RUNNING: " block) {inside=1; next}
        inside && $0 ~ ("\\[DONE\\] " block) {inside=0}
        inside && /128\^3 batch=4/ && $0 ~ ("Thr:[[:space:]]*" thr "[[:space:]]*\\|") {
            if (match($0, /Fwd:[[:space:]]*[0-9.]+ ms[[:space:]]*([0-9.]+) GFLOPS/, m)) {
                print m[1]; exit;
            }
        }
    ' "$LOGFILE"
}
```

This awk script scans the log for the first occurrence of `128^3 batch=4` with the specified thread count within the outer scenario block. It extracts the forward GFLOPS value. The summary table at the end uses `128^3 batch=4` as the single representative data point:

```
Scenario 1  :  7.30 GFLOPS   (SSE4.2, 1 thread)
Scenario 2  : 10.47 GFLOPS   (AVX512, 1 thread)     1.43x
Scenario 3  : 54.07 GFLOPS   (AVX512, 10 threads)   7.41x
Scenario 3b : 60.99 GFLOPS   (AVX512, 20 threads)   8.35x
```

---

## 6. Thread Concepts in This Benchmark

### 6.1 How many cores and threads exist

The Xeon W-2155 has:
- 10 **physical cores** — each is a complete processing unit with its own L1 and L2 cache
- 20 **logical threads** — each physical core has 2 hardware threads (Hyper-Threading), appearing as separate CPUs to the OS
- Each physical core's 2 HT siblings share the same L1d (32 KB), L1i (32 KB), and L2 (1 MB)
- All 10 cores share the L3 (14 MB)

### 6.2 Thread control flow

Thread count is set in three places, with a precedence order:

```
Shell sets: OMP_NUM_THREADS=N, MKL_NUM_THREADS=N
  ↓ (passed as argv[1] to binary)
C calls: mkl_set_num_threads(num_threads)  [overrides env vars]
  ↓
MKL internally spawns N threads, distributes FFT work
```

`mkl_set_num_threads()` inside `run_benchmark` is the authoritative control. This is why SCENARIO 4 (thread scaling sweep) can use thread counts `{1,2,4,8,10,20}` even during an outer run that was launched with `OMP_NUM_THREADS=1` — each `run_benchmark` call resets the thread count for that call.

### 6.3 How MKL threads parallelize an FFT

A 3D FFT of shape `nx × ny × nz` is decomposed as three sets of 1D FFTs:
1. `ny × nz` transforms of length `nx` (across all rows in the X direction)
2. `nx × nz` transforms of length `ny` (across all rows in the Y direction)
3. `nx × ny` transforms of length `nz` (across all rows in the Z direction)

MKL distributes these 1D FFTs across threads. For `128^3`, there are `128 × 128 = 16,384` 1D FFTs in each direction pass. With 10 threads, each thread handles roughly 1,638 of them. This is a straightforward data-parallel decomposition.

The challenge: for the second and third direction passes, the data access pattern changes. Accessing elements in the Y direction requires a stride of `nx` elements, and in the Z direction a stride of `nx × ny`. For large grids, these strided accesses hit different cache lines, reducing effective bandwidth. MKL uses internal transpositions to convert strided to sequential access patterns.

### 6.4 Per-scenario thread details

| Section | Thread behavior |
|---------|----------------|
| C SCENARIO 1 | Always 1 thread (`mkl_set_num_threads(1)`) |
| C SCENARIO 2 | Always 1 thread |
| C SCENARIO 3 | Uses `cli_threads` (the outer scenario's thread count) |
| C SCENARIO 4 | Sweeps `{1,2,4,8,10,20}` regardless of outer context |
| C SCENARIO 5 | Uses `cli_threads` |

For outer Scenario 1 (1 thread), C SCENARIO 3 runs with 1 thread. For outer Scenario 3 (10 threads), C SCENARIO 3 runs with 10 threads. This means the "multithreaded" section is only truly multithreaded when the outer shell scenario is itself multithreaded.

---

## 7. Thread Scaling (SCENARIO 4): What It Means and What the Data Shows

### 7.1 What thread scaling measures

Thread scaling keeps **everything fixed** (same grid, same batch, same ISA) and varies only the thread count. The goal is to see whether performance increases linearly with thread count (ideal/linear scaling) or whether some bottleneck limits scaling.

Fixed: `128^3 batch=4` — two buffers of 256 MB total (DRAM-bound).

### 7.2 Actual data from the latest run (outer Scenario 3, AVX512)

```
Threads |  Fwd (ms) |  Fwd GFLOPS | Speedup vs 1-thr | Efficiency
--------|-----------|-------------|------------------|----------
   1    |  84.06 ms |  10.48      |  1.00x           | 100%
   2    |  46.57 ms |  18.91      |  1.81x           |  90%
   4    |  24.78 ms |  35.54      |  3.39x           |  85%
   8    |  17.94 ms |  49.09      |  4.68x           |  59%
  10    |  14.42 ms |  61.07      |  5.83x           |  58%
  20    |  14.07 ms |  62.61      |  5.98x           |  30%
```

Efficiency = (achieved speedup) / (ideal speedup) × 100%.

### 7.3 Interpreting the numbers

**1 → 2 threads**: Nearly ideal (90% efficiency). Two threads operating independently, each with its own L1/L2 cache, little interference.

**2 → 4 threads**: Still good (85%). Still fitting within the parallel decomposition with good cache behavior per thread.

**4 → 8 threads**: Significant drop in efficiency (85% → 59%). At 8 threads, the aggregate working set that all threads access starts to saturate L3 cache bandwidth and the DRAM bus. The 256 MB working set is already far beyond L3 (14 MB). At 8 threads trying to pull 256 MB from DRAM simultaneously, the memory controller becomes the bottleneck.

**10 → 20 threads**: Essentially no improvement (62.61 vs 61.07 GFLOPS, 2.4% gain). The machine is 100% memory-bandwidth-limited at this point. Adding hyperthreads shares the same physical core and its memory access ports — they compete for the same bandwidth rather than adding new bandwidth.

**Key insight**: For `128^3 batch=4`, the parallel efficiency collapses well before 10 threads because the problem is DRAM-bound. The "thread scaling" section is valuable for revealing this, but labeling it as showing "how FFT scales across 10 physical cores" is slightly optimistic — it shows *where* scaling stops, which is at ~4-8 threads for this memory-bound problem.

### 7.4 Comparison across outer scenarios

An important quirk: SCENARIO 4 runs inside every outer scenario. So you can compare thread scaling in the SSE4.2 run (outer Scenario 1) vs the AVX-512 run (outer Scenario 3):

**Outer Scenario 1 (SSE4.2):**
```
thr=1:  120.24 ms,  7.33 GFLOPS
thr=10:  19.77 ms, 44.55 GFLOPS
thr=20:  15.45 ms, 57.00 GFLOPS
```

**Outer Scenario 3 (AVX512):**
```
thr=1:   84.06 ms, 10.48 GFLOPS
thr=10:  14.42 ms, 61.07 GFLOPS
thr=20:  14.07 ms, 62.61 GFLOPS
```

The 1-thread baseline is meaningfully faster with AVX512 (10.48 vs 7.33 GFLOPS = 1.43x). At 20 threads, the gap narrows (62.61 vs 57.00 GFLOPS = ~10% difference) because DRAM bandwidth becomes the common bottleneck. AVX-512 computes faster but cannot overcome the memory wall any better than SSE4.2 when bandwidth is the limit.

---

## 8. Batch Scaling (SCENARIO 5): What It Means and What the Data Shows

### 8.1 What batch scaling measures

Batch scaling keeps **grid and thread count fixed** and varies how many simultaneous transforms are issued in one DFTI call. Goal: measure throughput per transform as batch size increases.

Theory: batching should improve throughput because:
1. MKL computes twiddle factor tables once and reuses them across all transforms in the batch
2. Larger call granularity reduces per-call setup overhead
3. Better memory access patterns can emerge when MKL has visibility into the full batch

### 8.2 Actual data (outer Scenario 3, AVX512, 10 threads)

```
batch  |  Fwd (ms) |  GFLOPS | Time per transform
-------|-----------|---------|-------------------
  1    |   3.27 ms |  67.44  |  3.27 ms
  2    |   7.22 ms |  61.04  |  3.61 ms
  4    |  14.56 ms |  60.49  |  3.64 ms
  8    |  29.08 ms |  60.58  |  3.63 ms
 16    |  63.18 ms |  55.76  |  3.95 ms
 32    |  97.62 ms |  72.18  |  3.05 ms
```

Interesting pattern: the per-transform time is roughly flat (3.05–3.95 ms) across all batch sizes. With 10 threads on 128^3, we're memory-bound — the DRAM bandwidth is saturated by even a single transform. Doubling batch doubles the data, which doubles the time, which keeps GFLOPS approximately constant.

The slight uptick at batch=32 (72.18 GFLOPS) may reflect MKL finding a more efficient memory access pattern for the larger batched call, or it may be statistical noise across 20 runs.

### 8.3 Actual data (outer Scenario 1, SSE4.2, 1 thread)

```
batch  |  Fwd (ms) |  GFLOPS | Note
-------|-----------|---------|------
  1    |  29.45 ms |   7.48  |
  2    |  59.32 ms |   7.42  |
  4    | 123.75 ms |   7.12  |
  8    | 247.30 ms |   7.12  |
 16    | 432.95 ms |   8.14  | slight uptick
 32    | 851.63 ms |   8.27  | slight uptick
```

Same pattern at 1 thread — flat GFLOPS because 128^3 at 1 thread is also DRAM-bound (a single core can saturate DRAM if reading sequentially).

### 8.4 Why batch benefits are not visible here

The benefit of batching should appear when the twiddle factor tables fit in cache but the data does not, or when setup overhead is significant relative to computation. For 128^3:
- Twiddle tables for a single 128^3 3D FFT are on the order of several MB — borderline L3
- Working data is 32 MB per transform — well beyond L3
- Adding more transforms stacks more data, with no benefit from twiddle reuse since the tables were already computed once per `DftiCommitDescriptor`

**Where batch benefits would actually be visible**: a grid size like 32^3 (512 KB per transform). At batch=1, the working set fits in L2. At batch=16, it's 8 MB — still within L3. The GFLOPS curve would increase from batch=1 to batch=16 because twiddle tables stay in cache as all 16 transforms reuse the same 1D plans. This size is not benchmarked. Section 10 covers this.

---

## 9. AVX-512 Utilization: Is It Actually Working?

### 9.1 Evidence that AVX-512 is active

**Evidence 1: MKL_VERBOSE output**
```
MKL_VERBOSE oneMKL 2025 Update 3 Product build 20251007 for Intel(R) 64 architecture
Intel(R) Advanced Vector Extensions 512 (Intel(R) AVX-512) enabled processors, Lnx 3.30GHz intel_thread
MKL_VERBOSE FFT(dcfi64x64x64,...) 3.61ms CNR:OFF Dyn:0 FastMM:1 TID:0 NThr:1
```
The "Intel(R) AVX-512 enabled processors" line confirms MKL recognized and activated AVX-512. This is the most authoritative confirmation.

**Evidence 2: Measured speedup at compute-bound sizes**
For `64^3` (fits in L3, compute-bound), the 1-thread AVX-512 vs SSE4.2 comparison:
- SSE4.2 (outer Scenario 1, C SCENARIO 1): `64^3 batch=1` → 2.140 ms, 11.02 GFLOPS
- AVX-512 (outer Scenario 2, C SCENARIO 1): `64^3 batch=1` → 1.146 ms, 20.59 GFLOPS

**1.87x speedup at 64^3**. Since SSE4.2 can operate on 2 complex doubles per instruction and AVX-512 can operate on 8 (4x wider), with efficiency losses the ~2x observed speedup is plausible. This is hardware-confirmed vectorization doing real work.

**Evidence 3: AVX-512 compiled flags**
GCC was given `-mavx512f -mavx512dq -mavx512bw -mavx512vl` for `fft_avx512`. The MKL runtime correctly identified the processor as AVX-512 capable.

### 9.2 Where AVX-512 helps vs where it's irrelevant

At 64^3 (L3-resident, compute-bound): **AVX-512 provides real ~2x throughput improvement.**

At 128^3 and 256^3 (DRAM-bound): **AVX-512 advantage is minimal.** The bottleneck is DRAM bandwidth, not compute. Compare:
- 128^3 batch=1, 1 thread: SSE4.2 → 7.22 GFLOPS, AVX512 → ~11 GFLOPS (modest ~1.5x)
- 256^3 batch=1, 1 thread: SSE4.2 → 7.42 GFLOPS, AVX512 → 8.29 GFLOPS (modest ~1.1x)

As size increases, the memory-bound fraction increases, and the AVX-512 advantage shrinks.

### 9.3 One concern: "SSE4.2 binary" still gets AVX-512 GFLOPS in some output

In the outer Scenario 2 run (fft_avx512 binary, MKL_ENABLE_INSTRUCTIONS=AVX512), the C program's internal "SCENARIO 1 — CPU ONLY" section runs with the **same AVX-512 ISA** as "SCENARIO 2". The C labels are incorrect. The "CPU ONLY" section inside the AVX binary does NOT run as SSE4.2 — it runs at AVX-512. This is a labeling bug detailed in section 10.

---

## 10. Discrepancies in the Current Benchmarking

These are the honest problems with the current setup. Some are minor, some are significant.

### 10.1 The two-binary design is almost irrelevant to FFT performance

The biggest structural issue: compiling `fft_cpu_only` with `-O2` (no AVX) and `fft_avx512` with `-O3 -mavx512...` affects only the *host code* — the C code in `fft_benchmark.c` itself. The actual FFT computation runs inside MKL, which is a pre-compiled library. MKL selects its internal kernel based on `MKL_ENABLE_INSTRUCTIONS`, not based on how the calling program was compiled.

The compile flags matter for things like the random initialization loop and `get_time_ms()` — neither of which affects benchmark results.

**What actually controls the ISA**: `MKL_ENABLE_INSTRUCTIONS`. You could compile both binaries identically and get the same FFT timing results by just changing this environment variable.

This makes the two-binary design somewhat theatrical. The true comparison is `MKL_ENABLE_INSTRUCTIONS=SSE4_2` vs `MKL_ENABLE_INSTRUCTIONS=AVX512`, not "the binary compiled without AVX flags" vs "the binary compiled with AVX flags."

### 10.2 Internal C section labels are wrong in AVX runs

When `fft_avx512` runs with `MKL_ENABLE_INSTRUCTIONS=AVX512`, its internal output says:

```
SCENARIO 1 — CPU ONLY (1 thread, scalar baseline)
NOTE: Set by compile flag -O2  — no explicit AVX enabled
```

This is incorrect. The binary is `fft_avx512`, compiled with AVX-512 flags, and `MKL_ENABLE_INSTRUCTIONS=AVX512`. The label "scalar baseline" is actively wrong and misleading. The numbers in this section are AVX-512 numbers.

Similarly, "SCENARIO 2 — CPU + AVX-512" in the same run is also AVX-512 — it's not adding anything over SCENARIO 1. Both sections in any given outer run use the exact same ISA and thread count (both forced to 1 thread). They produce nearly identical results.

In the actual log for outer Scenario 2, comparing the two sections:
```
C SCENARIO 1:  64^3 batch=1 → 1.146 ms, 20.59 GFLOPS
C SCENARIO 2:  64^3 batch=1 → 1.124 ms, 20.99 GFLOPS
```
These are statistically identical, confirming there is no difference between C SCENARIO 1 and C SCENARIO 2 within any single outer run.

### 10.3 SCENARIO 4 runs inside outer Scenario 1 with SSE4.2 — thread sweep in low-ISA mode

When outer Scenario 1 (SSE4.2, 1 thread) is running, C's SCENARIO 4 sweeps threads from 1 to 20. So you get a thread scaling curve under SSE4.2 conditions. This is not explained anywhere in the output, and could confuse someone comparing the SCENARIO 4 output without checking which outer run produced it.

### 10.4 SCENARIO 5 label says "max threads" but uses `cli_threads`

```c
section("SCENARIO 5 — Batch Scaling Sweep (128^3, max threads)");
```

The label says "max threads" but the code uses:
```c
run_benchmark(128, 128, 128, batch_sizes[b], cli_threads, ...);
```

In outer Scenario 1 (1 thread), `cli_threads=1`. So SCENARIO 5 is a 1-thread batch sweep, not a max-thread batch sweep. The label lies.

In outer Scenario 3 (10 threads), it is running at 10 threads, which happens to be the physical core count. So the label is only accurate for one of the four outer runs.

### 10.5 No warmup between C sections

The warmup runs happen at the start of each `run_benchmark` call. When transitioning from one `run_benchmark` call to the next, if the problem size changes significantly, the AVX-512 frequency might already be stabilized. But if there's any idle time between calls (function overhead, printf), the CPU might briefly return to its base frequency. The 5 warmup runs at the start of the new configuration mitigate this, but for very small transforms (64^3, ~1ms each), 5 runs = 5ms may not be enough to re-settle.

For the large 256^3 cases (~250ms each), 5 warmup runs = 1.25 seconds of warmup — more than sufficient.

### 10.6 No correctness validation

The benchmark measures speed only. There is no check that `IFFT(FFT(x)) ≈ x`. MKL's IFFT does not normalize by N, so the round-trip produces `N × x`, not `x`. Without a validation step, you cannot confirm that the output is correct FFT data (not just fast garbage due to a misconfigured descriptor or bug).

This matters especially when testing edge cases, new batch configurations, or if MKL is misconfigured.

### 10.7 Summary extracts only one data point

The final summary shows only `128^3 batch=4` forward GFLOPS. This single number:
- Is DRAM-bound, so it reflects memory bandwidth more than compute
- Misses the compute-bound regime entirely (64^3 is not in the summary)
- Does not show backward FFT performance
- Hides batch scaling behavior

Someone reading only the summary would underestimate AVX-512's compute benefit (which shows as ~2x at 64^3, not the ~1.4x shown at 128^3).

### 10.8 Batch scaling tests the wrong size for observing batch benefits

As explained in section 8.4: 128^3 is DRAM-bound with any thread count at batch≥1. The batch size sweep at 128^3 measures how well DRAM bandwidth scales with batch (it doesn't really), not the FFT's twiddle factor reuse benefit. To see the actual benefit of batching, you need a compute-bound size like 32^3 or 48^3.

### 10.9 The "CPU-only" framing misrepresents what the baseline is

The baseline (`fft_cpu_only`, `MKL_ENABLE_INSTRUCTIONS=SSE4_2`) is not "CPU-only scalar code." It is MKL running with SSE4.2 instructions, which still includes SIMD operations — just 128-bit wide instead of 512-bit. SSE4.2 can still process 2 complex doubles per instruction. A truly scalar baseline would be a non-vectorized reference FFT implementation (like FFTW in scalar mode, or a hand-written naive DFT). The current benchmark's "baseline" is really "narrower SIMD MKL" vs "wider SIMD MKL."

This overstates the baseline and understates the absolute AVX-512 advantage.

---

## 11. What Is Useful vs What Is Less Useful

### Genuinely useful

**Outer scenario comparison (Scenario 1/2/3/3b)**: The four outer modes isolate ISA and thread count as variables. The summary table directly shows the compounding effect of AVX-512 + threading. The `7.30 → 10.47 → 54.07 → 60.99 GFLOPS` progression across Scenario 1/2/3/3b tells a clear story.

**Thread scaling sweep (SCENARIO 4) in AVX-512 outer runs**: Shows the actual scaling curve, confirms where memory bandwidth becomes the bottleneck, and establishes whether HT (threads 10→20) provides additional value. The data clearly shows the inflection point at 8–10 threads.

**Large-size behavior (256^3)**: Shows the fully memory-bound regime where per-transform time exceeds 100ms and ISA differences shrink significantly. Useful for understanding real-application performance at production scales.

**The MKL_VERBOSE confirmation**: Definitive proof that AVX-512 is actually being used. This is more reliable than inferring from GFLOPS numbers alone.

### Less useful / potentially misleading

**C SCENARIO 1 and C SCENARIO 2 in any given outer run**: They produce identical numbers with different labels. Reading them side-by-side suggests a comparison that isn't happening.

**Batch scaling at 128^3 (SCENARIO 5)**: Does not demonstrate the benefit it claims to. For any thread count, 128^3 is DRAM-bound, and GFLOPS stays flat across batch sizes. The section title "Shows benefit of batched FFT vs repeated single calls" overpromises.

**SCENARIO 3 in outer Scenario 1 and 2 (1-thread runs)**: The "multithreaded" section runs at 1 thread. It adds extra grid/batch combinations but is redundant with what SCENARIO 1 and 2 already show.

**The full set of 5 inner sections × 4 outer runs = 20 sections**: Most of the data is redundant. The truly unique measurements are: 1-thread SSE4.2, 1-thread AVX512, 10-thread AVX512, 20-thread AVX512, the thread scaling curve, and the batch scaling curve.

---

## 12. How to Make It Better

### High impact

**1. Add a 32^3 or 48^3 grid size**
This is the single most impactful improvement for demonstrating batch scaling benefits. 32^3 = 512 KB per transform, fully L2-resident. At batch=1 to batch=32, you would see the GFLOPS increase as twiddle tables stay warm in L3 while data streams through. Currently the benchmark never shows this regime.

**2. Fix the inner section labels or remove the redundancy**
Options:
- Remove C SCENARIO 1 and C SCENARIO 2 from the C file entirely. The shell's outer scenarios already isolate ISA. The inner sections add nothing.
- Or rename them: if kept, label them as "Grid sweep (1 thread)" without implying an ISA context, since ISA is controlled externally.

**3. Add correctness validation**
After the timing runs, compute `IFFT(FFT(input))` on a small test case and compare to `N × input`. Compute the relative L2 norm:
```
error = ||IFFT(FFT(x)) - N*x||_2 / (N * ||x||_2)
```
This should be below ~1e-13 for double precision. Printing this once per run configuration confirms the FFT is producing correct results, not just fast output.

**4. CSV output mode**
Add a flag to output machine-readable CSV alongside the human-readable table:
```
outer_mode,section,nx,ny,nz,batch,threads,fwd_ms,bwd_ms,fwd_gflops,bwd_gflops
SSE4_2_1T,grid_sweep,64,64,64,1,1,2.140,2.036,11.02,11.59
...
```
This makes the data importable into Python/R/Excel for plotting without needing log-parsing awk scripts.

**5. Per-run statistics (min/mean/stddev), not just mean**
Currently the benchmark averages 20 runs silently. For multithreaded DRAM-bound workloads, run-to-run variance can be 5–15%. Printing min/mean/stddev would reveal stability issues and outliers.

### Medium impact

**6. Add AVX2 intermediate ISA**
`MKL_ENABLE_INSTRUCTIONS=AVX2` would give a three-way ISA comparison: SSE4.2 → AVX2 → AVX512. This isolates the SIMD width contribution (128-bit → 256-bit → 512-bit) more cleanly.

**7. Fix the SCENARIO 5 label from "max threads" to "cli_threads"**
One-line fix in the C code. Reduces confusion when reading 1-thread outer run output.

**8. Add a non-power-of-2 grid test**
Include one grid like `100^3` or `192^3`. These force MKL to use mixed-radix decompositions instead of pure Cooley-Tukey. The performance difference is often 2–5x slower. This matters if target applications use non-standard grid sizes.

**9. Separate the thread scaling sweep into its own outer mode**
Currently thread scaling runs inside every outer mode (producing 4 nearly-identical curves). Running it once with the AVX-512 binary and once with the SSE4.2 binary would produce the two genuinely different curves without the redundancy.

### Low impact but adds confidence

**10. Include FFTW as a comparison**
FFTW with wisdom enabled is the competitive alternative to MKL. On Intel hardware MKL typically wins, but having the comparison makes the "why MKL" choice evidence-based rather than assumed. The copilot notes mention this as an option.

---

## 13. Reading Logs Confidently

When you open a log file, do this in sequence:

1. **Find the outer run header** — this anchors everything:
   ```
   RUNNING: Scenario 3 — AVX-512 + physical cores
   Binary : fft_avx512
   Threads: 10
   ISA    : AVX512
   ```

2. **Check MKL max threads at the binary header** — confirms the env var took effect:
   ```
   MKL max threads available : 10
   ```

3. **Find the C section you want** by name (SCENARIO 1..5). Remember C SCENARIO 1 and 2 are identical in any run that uses `fft_avx512`.

4. **For apples-to-apples comparison**: compare the same grid + batch + thread count across different outer runs.

5. **Use the summary at the bottom of the log as a first pass**, then drill into SCENARIO 4 (thread scaling) for parallelism analysis and SCENARIO 3 (grid/batch sweep) for working-set analysis.

6. **Never compare a number from one outer run's SCENARIO 4 against another outer run's SCENARIO 3** without first checking the thread count matches.

---

## 14. Key Numbers at a Glance (from last full run)

### AVX-512 vs SSE4.2 (1 thread, compute-bound 64^3)
```
SSE4.2 : 64^3 batch=1 → 11.02 GFLOPS
AVX512 : 64^3 batch=1 → 20.59 GFLOPS   (+87%, nearly 2x)
```

### Thread scaling at 128^3 batch=4, AVX512
```
1 thr  :  84 ms, 10.5 GFLOPS  (baseline)
2 thr  :  47 ms, 18.9 GFLOPS  (1.81x)
4 thr  :  25 ms, 35.5 GFLOPS  (3.39x)
8 thr  :  18 ms, 49.1 GFLOPS  (4.68x) ← efficiency drops here
10 thr :  14 ms, 61.1 GFLOPS  (5.83x)
20 thr :  14 ms, 62.6 GFLOPS  (5.98x) ← HT provides <3% gain
```

### Full stack speedup (1-thread SSE4.2 → 10-thread AVX512)
```
128^3 batch=4: 7.30 → 54.07 GFLOPS = 7.4x total speedup
64^3 batch=1:  11.02 → 123.28 GFLOPS = 11.2x total speedup (compute-bound, bigger AVX benefit)
```

### Memory pressure summary
```
64^3  batch=1  →   8 MB  (L3-resident, compute-bound)
128^3 batch=4  → 256 MB  (DRAM-bound, bandwidth-limited)
256^3 batch=4  → 2 GB    (deeply DRAM-bound)
```

---

## 15. Summary

This is a real, functional MKL DFTI performance benchmark. AVX-512 is genuinely active (confirmed by `MKL_VERBOSE` and by measured ~2x speedup at compute-bound sizes). Thread scaling behaves correctly — strong up to ~8 threads, then memory-bandwidth-limited. Hyper-Threading provides marginal benefit for this workload.

The main structural problems are:
- Two binary design that doesn't actually control ISA (the env var does)
- Internal C section labels that are wrong when running the AVX binary
- Batch scaling tested on a size where batch benefits cannot appear
- Redundant repeated sections across outer runs
- No correctness validation

None of these affect the validity of the comparison between outer Scenario 1/2/3/3b, which is the primary purpose. The benchmark gives trustworthy numbers for the four outer scenarios. Everything else is noise or could be made cleaner with targeted structural changes.
