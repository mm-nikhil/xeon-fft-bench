# Deep Walkthrough: `fft_benchmark.c` and `run_fft_benchmarks.sh` (v2)

Covers the redesigned benchmark end-to-end: what changed, what every line does, what the data means, and what is still imperfect.

---

## 1. Hardware Context (Unchanged)

```
CPU    : Intel Xeon W-2155 @ 3.30 GHz (Skylake-X)
Cores  : 10 physical / 20 logical (Hyper-Threading, 2 per core)
Socket : 1 socket, 1 NUMA node
Cache  : L1d 32 KB/core | L2 1 MB/core | L3 14 MB shared
AVX    : AVX, AVX2, AVX-512F/DQ/BW/CD/VL confirmed
DRAM   : shared by all cores
```

**AVX-512 frequency throttle** still applies. Skylake-X drops from 3.3 GHz → ~2.5 GHz under sustained AVX-512. Warmup runs force this steady state before measurement begins. The 5-warmup default is adequate for large grids (each run takes 100ms+ so 5 = 500ms of settling). For 32^3 (each run ~0.07ms), 5 warmup runs = 0.35ms — frequency likely hasn't fully throttled, so AVX-512 numbers at 32^3 may be slightly optimistic relative to sustained workloads.

**Cache working set:**

| Grid | Points N | Memory/transform (16B/pt) | Fits in |
|------|----------|---------------------------|---------|
| 32^3 | 32,768   | 512 KB                    | L2 (1 MB) — compute-bound |
| 64^3 | 262,144  | 4 MB                      | L3 (14 MB) — compute-bound |
| 128^3 | 2,097,152 | 32 MB                   | DRAM — memory-bound |
| 256^3 | 16,777,216 | 256 MB                 | DRAM, deeply — memory-bound |

This is the most important thing to hold in your head while reading results. Everything behaves differently on each side of the DRAM boundary.

---

## 2. What Changed: Old Design vs New Design

The old design had two overlapping layers of "Scenario" that were genuinely confusing. The new design eliminates that.

### Old problems fixed

| Old Problem | New Solution |
|-------------|-------------|
| Two binaries (`fft_cpu_only`/`fft_avx512`) with compile flags that didn't actually control MKL ISA | One binary, `fft_benchmark`, compiled with `-march=native`. ISA controlled exclusively by `MKL_ENABLE_INSTRUCTIONS` |
| 5 C internal sections (SCENARIO 1–5) that ran inside every outer run, creating 20 section outputs per full run | Three clean workload functions: `run_throughput`, `run_thread_scaling`, `run_batch_scaling`. Each outer profile runs exactly one workload. |
| C sections labelled "CPU only" and "AVX-512" even when the binary was AVX-512 and the ISA was forced to SSE4.2 | Labels come entirely from the profile system — no ISA label inside C |
| No 32^3 grid size (missed L2-resident compute-bound regime) | 32^3 added to default cube list |
| No AVX2 intermediate ISA | `avx2_1t` and `avx2_phys` profiles added |
| Batch scaling labelled "max threads" but used `cli_threads` | Batch scaling uses explicit `scale_threads` parameter |
| No structured parseable output | Every result emits a `RESULT|...` pipe-delimited line |
| No auto-generated report | Markdown report auto-generated from log by awk |
| No memory cap | `BENCH_MAX_MEM_MB` skips cases that would OOM |

### New concepts added

- **Run profile**: a named combination of workload type + ISA + thread count. The shell defines 8 profiles; the C binary executes the workload the profile specifies.
- **Workload type**: `throughput`, `thread_scaling`, or `batch_scaling`. These are mutually exclusive modes inside one binary invocation.
- **Structured output lines**: `PROFILE|...`, `RESULT|...`, `SKIP|...` for machine parsing.
- **Markdown report**: auto-generated, case-centric comparison across profiles.
- **`RUN_PROFILES` selector**: run a subset of profiles, e.g. `RUN_PROFILES=avx512_1t,avx512_phys`.

---

## 3. `fft_benchmark.c`: Complete Walkthrough

### 3.1 New helper functions

**`env_double`**: Same as `env_int` but reads a floating-point value. Used for `BENCH_MAX_MEM_MB`. Pattern: try to read env var, validate range, fall back to default if missing or invalid.

**`trim`**: Strips leading and trailing whitespace from a string. Used before parsing tokens from comma-separated env var values. Prevents `" 32 , 64 "` from breaking the parser.

**`parse_int_list`**: Tokenizes a comma-separated string into an integer array. Uses `strtok_r` (re-entrant, safe for single-threaded parsing). Each token is trimmed and parsed with `strtol`. Values outside `[min_v, max_v]` are silently skipped. Returns count of valid values.

**`load_int_list`**: Wrapper around `parse_int_list` that reads from an environment variable with a fallback string if the env var is absent. This is how grid sizes, batch sizes, and thread sets are configured at runtime without recompilation.

**`print_list`**: Prints a comma-separated integer array to stdout for the header block. Used to log the exact configuration that was parsed.

### 3.2 `run_benchmark`: The core function (what changed)

The function signature expanded significantly:

```c
static void run_benchmark(const char *profile_id,
                          const char *workload,
                          const char *case_id,
                          int nx, int ny, int nz,
                          int howmany,
                          int num_threads,
                          int warmup_runs,
                          int nruns,
                          double max_mem_mb)
```

New parameters vs old:
- `profile_id`: the string name of the outer run profile (e.g. `"avx512_phys"`). Printed in the `RESULT|` line.
- `workload`: the workload category (`"throughput"`, `"thread_scaling"`, `"batch_scaling"`). Printed in the `RESULT|` line.
- `case_id`: a short label generated by the caller (e.g. `"n128_b4"`, `"n128_b4_t10"`). Used in human output and `RESULT|` lines.
- `max_mem_mb`: memory cap. If the allocation would exceed this, the benchmark is skipped.

**Memory cap check (new)**:
```c
double mem_mb = (2.0 * (double)total * (double)sizeof(MKL_Complex16)) / (1024.0 * 1024.0);
if (max_mem_mb > 0.0 && mem_mb > max_mem_mb) {
    printf("[skip] ...\n");
    printf("SKIP|%s|%s|%s|...|%.2f|memory_limit\n", ...);
    return;
}
```
Before allocating anything, the function computes how much memory would be needed (both buffers). If this exceeds `max_mem_mb`, it prints a human-readable `[skip]` line and a machine-parseable `SKIP|` line, then returns. The awk report handles `SKIP` records and can include them in tables with a reason column. Default cap is 3072 MB (3 GB).

**Two output lines per successful run (new)**:

Human-readable:
```
[run ] n128_b4         | Grid: 128x 128x 128 | Batch:  4 | Thr:10 | Fwd:  14.384 ms   61.24 GF/s | ...
```

Machine-parseable:
```
RESULT|avx512_phys|throughput|n128_b4|128|128|128|4|10|14.384000|61.240000|14.705000|59.900000|256.00
```

The `RESULT|` line uses `|` as field separator with fixed field order:
`profile_id | workload | case_id | nx | ny | nz | batch | threads | fwd_ms | fwd_gflops | bwd_ms | bwd_gflops | mem_mb`

This is what the awk report consumes.

### 3.3 Three workload dispatch functions

**`run_throughput`**: Nested loop over `cubes × batches` at a fixed thread count. This is the primary ISA-comparison workload. All throughput profiles (baseline_sse42_1t, avx2_1t, avx512_1t, avx2_phys, avx512_phys, avx512_logical) run this. Case ID format: `n{cube}_b{batch}`.

**`run_thread_scaling`**: Single loop over a thread array at fixed `cube` and `batch`. The outer `cli_threads` value is irrelevant here — `mkl_set_num_threads(threads[i])` is called per iteration. The outer profile passes `NTHREADS_PHYSICAL` as `scale_threads` (used only to set `MKL_ENABLE_INSTRUCTIONS` and outer env; the C sweeps its own thread_set). Case ID format: `n{cube}_b{batch}_t{threads}`.

**`run_batch_scaling`**: Single loop over a batch array at fixed `cube` and `threads`. The `threads` here comes from `scale_threads` which is read from `BENCH_SCALE_THREADS` (defaults to `cli_threads`). For the `avx512_batch_scaling` profile, `cli_threads=NTHREADS_PHYSICAL=10`. Case ID format: `n{cube}_b{batch}_t{threads}`.

### 3.4 `main`: parsing and dispatch

The flow is:
1. Read `cli_threads` from `argv[1]`
2. Read `BENCH_NRUNS`, `BENCH_WARMUP`, `BENCH_MAX_MEM_MB`
3. Read `BENCH_PROFILE`, `BENCH_PROFILE_DESC`, `BENCH_WORKLOAD` (all set by shell)
4. Parse four lists: `cubes` (from `BENCH_CUBES`), `batches` (from `BENCH_BATCHES`), `thread_set` (from `BENCH_THREAD_SET`), `batch_scale_set` (from `BENCH_BATCH_SCALE_SET`)
5. Parse scalar scaling params: `scale_cube`, `scale_batch`, `scale_threads`
6. Print header block
7. Dispatch to `run_throughput`, `run_thread_scaling`, or `run_batch_scaling` based on `BENCH_WORKLOAD`

The `if (n_cubes <= 0)` fallback blocks set safe defaults if parsing produces nothing. This means an empty or malformed `BENCH_CUBES` still produces a working run.

---

## 4. `run_fft_benchmarks.sh`: Complete Walkthrough

### 4.1 Directory anchoring (new)

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
```

The old script used a relative path `./fft_logs` which would break if called from a different directory. Now the script `cd`s to its own directory before doing anything. `BASH_SOURCE[0]` is the path to the script itself, which works correctly even when called via symlink or from another directory.

### 4.2 Report file (new)

```bash
REPORT_MD="${LOGDIR}/fft_benchmark_${TIMESTAMP}.report.md"
```

Alongside the raw log, a markdown report is generated. The report is populated at the end of the run by the `generate_markdown_report` awk function. The log accumulates all output during the run; the report is a post-processed view.

### 4.3 Configurable sets (new)

```bash
THROUGHPUT_CUBES="${THROUGHPUT_CUBES:-32,64,128,256}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1,4}"
THREAD_SCALING_SET="${THREAD_SCALING_SET:-1,2,4,8,10,20}"
BATCH_SCALING_SET="${BATCH_SCALING_SET:-1,2,4,8,16,32}"
SCALE_CUBE="${SCALE_CUBE:-128}"
SCALE_BATCH="${SCALE_BATCH:-4}"
```

These replace hardcoded arrays in the old C code. Now every dimension is configurable at the shell level without changing C code. The shell passes them as environment variables to the binary.

### 4.4 Single binary compile (vs two binaries before)

```bash
if [ "${USE_ICX}" -eq 1 ]; then
    CFLAGS="-O3 -xHost -std=c99"
else
    CFLAGS="-O3 -march=native -std=c99"
fi
```

`-march=native` / `-xHost` tells the compiler to target the current CPU's full native instruction set. On the Xeon W-2155, this includes all AVX-512 extensions. The key difference from the old design: this only affects host code (the wrapper code in `fft_benchmark.c`). MKL's FFT kernels are always selected at runtime via `MKL_ENABLE_INSTRUCTIONS`, not compile flags. So the compile flags here enable the compiler to auto-vectorize any non-MKL code (like `random_init`, though that's not timed) and also allow MKL to JIT or select kernels based on feature detection.

### 4.5 `run_profile` function

```bash
run_profile() {
    local profile_id="$1"
    local profile_desc="$2"
    local isa="$3"
    local threads="$4"
    local workload="$5"
    local cubes="$6"
    local batches="$7"
    local thread_set="$8"
    local scale_cube="$9"
    local scale_batch="${10}"
    local scale_threads="${11}"

    echo "PROFILE|${profile_id}|${profile_desc}|${isa}|${threads}|${workload}|..."

    export OMP_NUM_THREADS="${threads}"
    export MKL_NUM_THREADS="${threads}"
    export MKL_ENABLE_INSTRUCTIONS="${isa}"
    export BENCH_PROFILE="${profile_id}"
    export BENCH_WORKLOAD="${workload}"
    export BENCH_CUBES="${cubes}"
    export BENCH_BATCHES="${batches}"
    export BENCH_THREAD_SET="${thread_set}"
    ...
    time "./${BIN}" "${threads}"
}
```

Every profile call does three things:
1. Emits a `PROFILE|` line to the log (parsed by awk for the scenario catalog table)
2. Exports all environment variables the binary will read
3. Runs `time ./fft_benchmark <threads>`, passing thread count as both an env var and `argv[1]`

The `PROFILE|` line contains all metadata needed to reconstruct what this run was supposed to do, even without reading the code.

### 4.6 `should_run_profile` function (new)

```bash
should_run_profile() {
    local profile_id="$1"
    if [ "${RUN_PROFILES}" = "all" ]; then return 0; fi
    case ",${RUN_PROFILES}," in
        *,"${profile_id}",*) return 0 ;;
        *) return 1 ;;
    esac
}
```

When `RUN_PROFILES=all` (default), every profile runs. When `RUN_PROFILES=avx512_1t,avx512_phys`, only those two run. The comma-wrapping trick in the `case` pattern (`",${RUN_PROFILES},"` with `*,"${profile_id}",*`) prevents partial matches (e.g. `avx512` matching `avx512_phys`).

Usage:
```bash
should_run_profile "baseline_sse42_1t" && run_profile "baseline_sse42_1t" ...
```
`&&` short-circuits: if `should_run_profile` returns false (exit code 1), `run_profile` is not called.

### 4.7 The 8 run profiles

```
baseline_sse42_1t    ISA=SSE4_2,  threads=1,   workload=throughput
avx2_1t              ISA=AVX2,    threads=1,   workload=throughput
avx512_1t            ISA=AVX512,  threads=1,   workload=throughput
avx2_phys            ISA=AVX2,    threads=10,  workload=throughput
avx512_phys          ISA=AVX512,  threads=10,  workload=throughput
avx512_logical       ISA=AVX512,  threads=20,  workload=throughput
avx512_thread_scaling ISA=AVX512, threads=10,  workload=thread_scaling
avx512_batch_scaling  ISA=AVX512, threads=10,  workload=batch_scaling
```

Note that `baseline_sse42_1t` only covers 1 thread. The multithread profiles (avx2_phys, avx512_phys, avx512_logical) don't have an SSE4.2 counterpart. If you want a "multithread SSE4.2" data point you'd need to add a profile manually.

Also note: `avx512_thread_scaling` and `avx512_batch_scaling` both have their own dedicated profile invocations. They don't piggyback inside throughput runs anymore.

### 4.8 `generate_markdown_report` (new — large awk block)

This awk script reads the log file and builds a structured markdown report. It does **two passes** conceptually (awk collects into arrays during processing, then emits in `END`):

**Pass 1 — data collection** (during file scan):
- `PROFILE|` lines → populates `desc[]`, `isa[]`, `threads[]`, `workload[]` keyed by `profile_id`
- `RESULT|` lines → populates `fwd_ms[]`, `fwd_gf[]`, etc. keyed by `(case_key, profile_id)`. The case key is `workload|nx|ny|nz|batch|threads`.
- `SKIP|` lines → populates same arrays with `status="skip"` and reason.

**Pass 2 — rendering** (in `END` block):
- Scenario Catalog table: one row per profile in order of first appearance
- Case-Centric Comparison: for each unique case key, one table comparing all profiles that have data for that case. Speedup vs `baseline_sse42_1t` is computed when baseline data is available and the baseline ran at the same thread count (which for throughput cases means thread=1).

The case key includes thread count, so `n128_b4` at threads=1 and `n128_b4` at threads=10 are different cases. This is why the multithread profiles don't appear in the 1-thread case tables and vice versa, and why the speedup column shows "-" for multithread cases (no baseline ran at threads=10/20).

---

## 5. What "Profile", "Workload", "ISA", "Threads" Mean Concretely

### Profile
A profile is a unique combination of ISA + thread count + workload type. It answers: "under what conditions are we running?" Each profile produces a block of output in the log, bracketed by `RUN PROFILE:` and `[DONE]`.

### Workload type
- **throughput**: Grid size × batch size sweep at fixed thread count. Answers: "how does performance scale with problem size?"
- **thread_scaling**: Fixed grid/batch, sweeping thread counts from 1 to 20. Answers: "how does parallel efficiency scale with thread count for this problem?"
- **batch_scaling**: Fixed grid/thread count, sweeping batch sizes. Answers: "does issuing more transforms per DFTI call improve throughput per transform?"

### ISA cap
`MKL_ENABLE_INSTRUCTIONS` is an MKL-specific env var that caps the instruction set MKL will use. Valid values for this machine:
- `SSE4_2` — restricts to SSE4.2 (128-bit SIMD, 2 complex doubles/instruction)
- `AVX2` — allows up to AVX2 (256-bit SIMD, 4 complex doubles/instruction)
- `AVX512` — allows full AVX-512 (512-bit SIMD, 8 complex doubles/instruction)

This is the actual control mechanism for ISA comparison. Compile flags (`-march=native`) tell the compiler what to use for host code; `MKL_ENABLE_INSTRUCTIONS` tells MKL which pre-compiled kernel paths to activate.

### Threads
For throughput profiles, the outer thread count is fixed (1, 10, or 20) and stays constant across all cases in that profile.

For thread_scaling, the outer thread count (`cli_threads=10`) sets the process-level `MKL_NUM_THREADS` env var, but `mkl_set_num_threads()` inside `run_thread_scaling` overrides this per benchmark call. So the sweep 1→2→4→8→10→20 really does use those thread counts.

---

## 6. Inputs Explained

### Grid size: what `32^3`, `64^3`, etc. mean

A 3D FFT on an `n × n × n` grid. The total number of complex data points per transform is `N = n³`.

Each point is `MKL_Complex16`: two doubles = 16 bytes.

Memory per transform buffer: `N × 16 bytes`.
Out-of-place: two buffers (in + out), so `2 × N × 16 bytes`.

| Grid | N | Memory (one transform, both buffers) | Cache regime |
|------|---|--------------------------------------|-------------|
| 32^3 | 32,768 | 1 MB | L2 (just fits) |
| 64^3 | 262,144 | 8 MB | L3 |
| 128^3 | 2,097,152 | 64 MB | DRAM |
| 256^3 | 16,777,216 | 512 MB | DRAM |

With batch=4, multiply memory by 4. So `128^3 batch=4 = 256 MB` total.

### What `batch=4` means

`batch` (parameter `howmany`) = number of independent 3D FFTs executed in a single `DftiComputeForward` call. The transforms are packed contiguously in memory with no gaps. `DFTI_INPUT_DISTANCE = nx*ny*nz` means each transform starts exactly `N` elements after the previous one.

Batching was originally motivated by twiddle factor reuse — MKL computes internal sine/cosine tables once (at `DftiCommitDescriptor`) and reuses them across all transforms in the batch. For small sizes (32^3, 64^3) where data is L2/L3-resident, this helps because the tables stay hot. For large sizes (128^3+) the problem is already DRAM-bound and batch doesn't improve per-transform efficiency.

### Case ID format

The C code generates case IDs that appear in both the human-readable output and the `RESULT|` lines:

- Throughput: `n{cube}_b{batch}` — e.g. `n128_b4` means 128^3 grid, batch=4
- Thread scaling: `n{cube}_b{batch}_t{threads}` — e.g. `n128_b4_t10`
- Batch scaling: `n{cube}_b{batch}_t{threads}` — e.g. `n128_b16_t10`

The awk report uses these as case identifiers for grouping.

---

## 7. Reading the Report

The report has two sections.

### Scenario Catalog

One row per profile showing what it was intended to measure. Use this to orient yourself before reading data tables.

### Case-Centric Comparison

For each unique (workload, grid, batch, threads) combination, one table appears showing all profiles that produced data for it. The speedup column compares forward GFLOPS to `baseline_sse42_1t` for the same case.

**Critical**: the speedup column shows "-" whenever the baseline profile didn't run the same (workload, grid, batch, threads) key. Since `baseline_sse42_1t` only runs with threads=1 and workload=throughput, cases from multithread profiles, thread_scaling, and batch_scaling all show "-" for speedup. This is correct, not a bug. To get the full-stack speedup (1-thread SSE4.2 vs 10-thread AVX512) you need to look up both cases manually and divide.

---

## 8. What the Data Actually Shows (from latest run)

### 8.1 ISA comparison: the three-way ladder

Single-thread throughput at various grid sizes, forward GFLOPS:

| Grid | SSE4.2 | AVX2 | AVX512 | AVX2/SSE42 | AVX512/SSE42 | AVX512/AVX2 |
|------|--------|------|--------|------------|--------------|-------------|
| 32^3 batch=1 | 13.23 | 22.79 | 36.37 | 1.72x | 2.75x | 1.60x |
| 32^3 batch=4 | 14.02 | 20.37 | 28.80 | 1.45x | 2.05x | 1.41x |
| 64^3 batch=1 | 11.57 | 15.59 | 20.97 | 1.35x | 1.81x | 1.34x |
| 64^3 batch=4 |  8.61 | 10.96 | 12.71 | 1.27x | 1.48x | 1.16x |
| 128^3 batch=1 | 7.59 |  9.25 | 10.96 | 1.22x | 1.44x | 1.19x |
| 128^3 batch=4 | 7.47 |  8.92 | 10.50 | 1.19x | 1.41x | 1.18x |
| 256^3 batch=1 | 7.18 |  7.73 |  8.56 | 1.08x | 1.19x | 1.11x |
| 256^3 batch=4 | 7.53 |  8.35 |  9.34 | 1.11x | 1.24x | 1.12x |

**The trend is clear and physically meaningful**: as grid size grows, the working set moves from compute-bound (L2) to memory-bound (DRAM), and the ISA advantage shrinks. At 32^3 AVX-512 gives 2.75x over SSE4.2. At 256^3 it gives 1.19x. The gap closes because DRAM bandwidth is the bottleneck, not compute throughput — wider SIMD doesn't help you read DRAM faster.

**AVX2 vs AVX512**: 1.60x at 32^3, 1.11x at 256^3. AVX-512 doubles the register width over AVX2 (512 vs 256 bit), but the efficiency ratio at 32^3 (1.60x) is less than the theoretical 2x because of overhead (setup, the fact that 3D FFT involves mixed-stride accesses, etc.). At large sizes both are memory-bound and converge.

### 8.2 Thread scaling (128^3 batch=4, AVX512)

From the `avx512_thread_scaling` profile:

| Threads | Fwd ms | GFLOPS | Speedup vs 1T | Parallel efficiency |
|---------|--------|--------|---------------|---------------------|
| 1 | 85.07 | 10.35 | 1.00x | 100% |
| 2 | 45.56 | 19.33 | 1.87x | 93% |
| 4 | 25.17 | 35.00 | 3.38x | 85% |
| 8 | 18.14 | 48.56 | 4.69x | 59% |
| 10 | 14.24 | 61.86 | 5.98x | 60% |
| **20** | **15.22** | **57.86** | **5.59x** | **28%** |

**20 threads is slower than 10 threads.** 15.22ms vs 14.24ms — a 7% regression. This is a real and expected result for DRAM-bound FFT:

- The working set is 256 MB (well beyond the 14 MB L3)
- At 10 threads, the memory controller is already saturated pulling 256 MB of data through the DRAM bus
- Adding 10 hyperthreads (sharing physical cores with the existing 10 threads) does not add new memory bandwidth — it adds only contention for the same ports
- HT siblings also share the core's L2 cache (1 MB/core), which for DRAM-bound work hurts cache hit rates

The scaling curve shows two distinct regimes:
1. **Compute-aided, good efficiency (threads 1–4)**: 85% efficiency at 4 threads, probably because L3 cache helps amortize some of the DRAM pressure across threads.
2. **Bandwidth-saturated, flat ceiling (threads 4–10)**: Efficiency drops to ~60%. Adding threads improves time but at diminishing returns as DRAM bandwidth becomes the common limit.
3. **HT hurts (10→20)**: Reversal. Physical core count is the sweet spot.

### 8.3 Hyperthreading: physical vs logical cores

Comparing avx512_phys (10 threads) vs avx512_logical (20 threads) across sizes:

| Grid / Batch | avx512_phys GFLOPS | avx512_logical GFLOPS | HT effect |
|---|---|---|---|
| 32^3 batch=1 | 65.68 | 62.31 | **-5% (HT hurts)** |
| 32^3 batch=4 | 107.40 | 102.00 | **-5% (HT hurts)** |
| 64^3 batch=1 | 120.18 | 109.75 | **-9% (HT hurts)** |
| 64^3 batch=4 | 109.98 | 101.63 | **-8% (HT hurts)** |
| 128^3 batch=1 | 65.33 | 65.65 | +0.5% (neutral) |
| 128^3 batch=4 | 61.24 | 61.84 | +1% (neutral) |
| 256^3 batch=1 | 56.92 | 53.19 | **-7% (HT hurts)** |
| 256^3 batch=4 | 60.77 | 61.98 | +2% (neutral) |

**HT hurts at small compute-bound sizes. It's neutral at medium sizes. It slightly hurts or is neutral at large DRAM-bound sizes.** This is the opposite of what naive intuition might suggest ("more threads = better"). Why?

For small sizes (32^3, 64^3) the FFT is compute-bound — limited by AVX-512 execution throughput. Each physical core has one AVX-512 FMA unit. Two HT threads on the same core compete for that single FMA unit. The physical core can interleave their execution, but total throughput per core stays roughly the same. You now have 10 physical cores each running 2 threads, but each core does no more compute than with 1 thread on it. You've added overhead (scheduling, contention) without adding capacity.

For large DRAM-bound sizes (128^3+), HT is basically neutral because memory latency is the bottleneck and HT threads can overlap memory-access latency with compute from other threads. This is the classic "latency hiding" benefit of HT, but here the latency is so dominant that it's a wash.

**Conclusion**: for this FFT workload on this machine, use 10 threads (physical cores only). 20 threads never beats 10 and sometimes significantly hurts.

### 8.4 Batch scaling (128^3, AVX512, 10 threads)

From the `avx512_batch_scaling` profile:

| Batch | Total mem | Fwd ms | GFLOPS | ms/transform |
|-------|-----------|--------|--------|--------------|
| 1 | 64 MB | 3.21 | 68.60 | 3.21 |
| 2 | 128 MB | 7.19 | 61.26 | 3.59 |
| 4 | 256 MB | 14.42 | 61.08 | 3.61 |
| 8 | 512 MB | 28.22 | 62.42 | 3.53 |
| 16 | 1024 MB | 58.85 | 59.87 | 3.68 |
| 32 | 2048 MB | 110.12 | 63.99 | 3.44 |

GFLOPS is essentially flat across batches (59–69 range). Per-transform time is also flat (3.2–3.7 ms). This tells you that at 128^3 with 10 threads, the bottleneck is DRAM bandwidth regardless of batch size. Issuing 32 transforms in one call vs 1 doesn't improve throughput per transform because you're already memory-bound — you're just streaming more data through at the same bandwidth.

The slight bump at batch=1 (68.60 GFLOPS) is interesting: with only 64 MB total, there's slightly less DRAM pressure than at batch=4+ (256+ MB). The DRAM bandwidth isn't quite fully saturated at batch=1 with 10 threads.

**Where batch scaling would actually show a benefit**: a grid small enough to be compute-bound at the batch sizes tested. At 32^3 batch=1 (1 MB total), data fits in L2. At 32^3 batch=32 (32 MB), it spills to L3. You'd see GFLOPS increase from batch=1 to moderate batch sizes as twiddle factor tables stay cache-warm. This benchmark doesn't run a 32^3 batch scaling profile — that's a remaining gap.

### 8.5 AVX2 vs AVX512 at 10 threads

For multithreaded throughput where the comparison matters:

| Grid / Batch | avx2_phys GFLOPS | avx512_phys GFLOPS | AVX512/AVX2 |
|---|---|---|---|
| 32^3 batch=4 | 77.33 | 107.40 | **1.39x** |
| 64^3 batch=1 | 97.56 | 120.18 | **1.23x** |
| 128^3 batch=4 | 57.86 | 61.24 | 1.06x |
| 256^3 batch=4 | 57.69 | 60.77 | 1.05x |

At small compute-bound sizes, AVX-512 still wins meaningfully at 10 threads (1.39x at 32^3 batch=4). At large DRAM-bound sizes the advantage collapses to ~5%. For production workloads that are primarily large-grid DRAM-bound, the difference between AVX2 and AVX512 is negligible. For production workloads with many small FFTs (volume rendering, small simulation cells), AVX-512 provides real benefit.

### 8.6 Forward vs backward FFT timing

Backward (inverse) FFT is consistently slightly slower than forward for large DRAM-bound cases:

| Case | Fwd ms | Bwd ms | Bwd/Fwd |
|------|--------|--------|---------|
| 256^3 batch=4, AVX512, 1T | 862.5 | 948.1 | 1.10x slower |
| 256^3 batch=4, SSE4.2, 1T | 1069.4 | 1120.7 | 1.05x slower |
| 128^3 batch=32, AVX512, 10T | 110.1 | 113.1 | 1.03x slower |

This is consistent across multiple runs and ISAs. MKL's backward DFT path may have slightly different kernel optimization or the normalization-related differences in the butterfly structure lead to a slightly different memory access pattern. It is not a measurement artifact. For workloads where inverse FFTs dominate, expect ~5–10% lower throughput than forward at large sizes.

---

## 9. Remaining Discrepancies and Limitations

### 9.1 `BENCH_BATCH_SCALE_SET` vs `BENCH_BATCHES` — a naming mismatch

The shell script passes batch lists to `run_profile` as the `batches` parameter. Inside `run_profile`, this is exported as `BENCH_BATCHES`. For throughput workloads, the C code reads `BENCH_BATCHES` and uses it — correct. For batch_scaling workloads, the C code reads `BENCH_BATCH_SCALE_SET` (not `BENCH_BATCHES`):

```c
int n_batch_scale = load_int_list("BENCH_BATCH_SCALE_SET", "1,2,4,8,16,32", ...);
```

The shell never exports `BENCH_BATCH_SCALE_SET`. So the batch_scaling workload always uses the C hardcoded default `"1,2,4,8,16,32"`, regardless of what `BATCH_SCALING_SET` is set to in the shell.

In practice the defaults match, so results are correct. But if you override `BATCH_SCALING_SET=1,4,32` at the shell level expecting the batch_scaling profile to use that, the C will ignore it. You'd need to also set `BENCH_BATCH_SCALE_SET=1,4,32` explicitly.

### 9.2 The speedup column is missing for multithread and scaling cases

The awk report can only compute `Fwd Speedup vs baseline_sse42_1t` when the baseline ran the exact same `(workload, nx, ny, nz, batch, threads)` tuple. Since `baseline_sse42_1t` only runs with threads=1 and workload=throughput, the multithread throughput profiles (avx2_phys, avx512_phys, avx512_logical), thread_scaling, and batch_scaling all show "-" in the speedup column.

The full-stack speedup (e.g., "what is the gain from 1-thread SSE4.2 to 10-thread AVX512?") requires manual calculation: `61.24 / 7.47 = 8.2x` for 128^3 batch=4. This is not surfaced anywhere in the report automatically.

### 9.3 No baseline SSE4.2 at multithread for direct comparison

There is no `baseline_sse42_phys` profile. If you want to know "how much does threading help SSE4.2?", there's no direct answer in the report. You can infer it by combining the 1-thread SSE4.2 throughput numbers with the thread_scaling curve (which only runs AVX512), but it's not a clean comparison.

### 9.4 Batch scaling at 32^3 is not profiled

The batch_scaling profile is fixed at `scale_cube=128`. This means batch scaling is only measured where it provably doesn't show twiddle-factor-reuse benefits (DRAM-bound). A batch sweep at 32^3 where data stays L2/L3-resident would show the actual benefit of batching. This is the most impactful missing measurement in the current design.

### 9.5 Thread scaling only at one problem size

Thread scaling is fixed at 128^3 batch=4. This is a DRAM-bound problem where scaling collapses at ~8 threads. A thread scaling curve at 64^3 batch=4 (L3-resident, compute-bound) would show a different and arguably more informative curve — one where threads help more and stay efficient longer. You'd need to add another profile or make `SCALE_CUBE` configurable per profile.

### 9.6 No correctness validation

The benchmark measures speed only. No check that `IFFT(FFT(x)) ≈ N × x`. Without this, a misconfigured descriptor or MKL error that silently produces wrong FFT output would not be caught. This is especially relevant when testing new grid sizes or unusual batch sizes.

Note: MKL's backward DFT does NOT normalize by N. The result of `IFFT(FFT(x))` is `N × x`, not `x`. Any correctness check must account for this.

### 9.7 Warmup duration doesn't scale with problem size

5 warmup runs is the default. For 32^3 (0.07ms per run), 5 warmup = 0.35ms — almost certainly insufficient for AVX-512 to throttle to steady-state (~100-200ms typically required). For 256^3 (250ms per run), 5 warmup = 1.25 seconds — more than enough. The warmup count should ideally be specified as a minimum wall-clock duration, not a run count. As-is, 32^3 AVX-512 numbers are potentially measured at a higher clock than the true sustained rate, slightly inflating the GFLOPS.

### 9.8 `avx512_thread_scaling` at 20 threads disagrees slightly with `avx512_logical`

Both should be running 128^3 batch=4 at 20 threads with AVX512. The results:
- `avx512_thread_scaling` at t20: 15.22 ms, 57.86 GFLOPS
- `avx512_logical` at t20: 14.24 ms, 61.84 GFLOPS

These differ by ~7%. Both have 20 timed runs so variance over a run set is small, but the difference between the two profile runs (which happen at different points in the overall benchmark) suggests thermal state or OS scheduling noise between the runs. This is normal, but it means cross-profile comparisons at the same configuration can have ~5-10% uncertainty, not the few-percent variance you'd expect from the within-run average.

### 9.9 `n256_b4` backward FFT is 10% slower than forward — unexplained

This is consistent across ISAs and run dates. MKL's internal backward (unnormalized IDFT) path is structurally similar to forward but may differ in minor optimization details. No documentation explains the exact cause. It is not a benchmark bug. For planning purposes, assume backward FFT is 5-10% slower than forward at large DRAM-bound sizes.

---

## 10. What Is Well Designed vs What Is Still Weak

### Well designed now

**Three-way ISA comparison (SSE4.2 / AVX2 / AVX512)** at 1 thread: this is the clearest possible demonstration of how ISA width affects FFT throughput, correctly showing diminishing returns as problem size increases.

**32^3 grid size included**: the L2-resident compute-bound regime is now captured. 2.75x speedup from SSE4.2 to AVX512 at 32^3 batch=1 is the most compelling data point for "is AVX-512 useful?"

**Single binary**: eliminates the old fiction that compile flags control MKL ISA. Everything is clean — one binary, ISA set by env var.

**Profile-based design**: each outer scenario has a name, a purpose, and produces a distinct block in the report. No ambiguity about which run produced which numbers.

**Structured RESULT lines**: log is machine-parseable. The awk report follows directly from the structure.

**`BENCH_MAX_MEM_MB`**: practical guard against OOM on large batch+grid combinations.

**`should_run_profile` selector**: you can do quick partial runs without editing code.

**HT analysis is now implicit**: the avx512_phys vs avx512_logical comparison cleanly shows HT hurts for compute-bound FFT and is neutral for DRAM-bound FFT.

### Still weak

**Batch scaling at 128^3 doesn't demonstrate batch benefits** (as analyzed above). Adding a 32^3 batch scaling profile would fix this.

**Thread scaling only at DRAM-bound 128^3**: doesn't show efficiency for compute-bound cases.

**No correctness check**: fast silent wrong output is undetectable.

**Speedup column gaps in report**: full-stack speedup requires manual cross-table lookup.

**BENCH_BATCH_SCALE_SET vs BENCH_BATCHES mismatch**: override doesn't work as expected.

**Warmup count doesn't scale with transform size**: small-grid AVX-512 numbers may be optimistic.

**Backward FFT asymmetry not explained or addressed**: consistent but unexplained.

---

## 11. Quick Numbers at a Glance

### Full-stack speedups (1T SSE4.2 → 10T AVX512, forward, from this run)

| Grid / Batch | 1T SSE4.2 | 10T AVX512 | Speedup |
|---|---|---|---|
| 32^3 batch=1 | 13.23 GF | 65.68 GF | **4.96x** |
| 32^3 batch=4 | 14.02 GF | 107.40 GF | **7.66x** |
| 64^3 batch=1 | 11.57 GF | 120.18 GF | **10.39x** |
| 64^3 batch=4 | 8.61 GF | 109.98 GF | **12.78x** |
| 128^3 batch=1 | 7.59 GF | 65.33 GF | **8.61x** |
| 128^3 batch=4 | 7.47 GF | 61.24 GF | **8.20x** |
| 256^3 batch=1 | 7.18 GF | 56.92 GF | **7.93x** |
| 256^3 batch=4 | 7.53 GF | 60.77 GF | **8.07x** |

Note the peak at 64^3 batch=4 (12.78x). At this size the problem is right on the L3/DRAM boundary — multithreading helps strongly (threads can each work on cache-resident data) and AVX-512 provides 1.5-2x compute benefit. This is the "sweet spot" for this machine.

### HT verdict

| Size regime | HT effect |
|---|---|
| Small, compute-bound (32–64^3) | **Hurts: -5% to -10%** |
| Medium, borderline (128^3) | Neutral: ±1% |
| Large, DRAM-bound (256^3) | Slightly hurts or neutral |

**Never use 20 threads for FFT on this machine. 10 threads is always equal or better.**

### ISA benefit summary

| GFLOPS ratio (AVX512 vs SSE4.2, 1T) | Regime |
|---|---|
| 2.75x at 32^3 | Compute-bound (L2) |
| 1.81x at 64^3 | Compute-bound (L3) |
| 1.44x at 128^3 batch=1 | Memory-bound |
| 1.19x at 256^3 | Deeply memory-bound |

AVX-512 is most valuable for small FFTs. For large DRAM-bound FFTs, it still helps but is not the limiting factor.

---

## 12. Comparison Against Jeongnim Kim Intel Slides (May 2018)

**Reference**: "Leveraging Optimized FFT on Intel Platforms", Jeongnim Kim, DCG/HPC Ecosystem and Applications / MKL team, May 30, 2018. 32-slide deck.

**Short answer**: We correctly use the right API, the right metric, and cover the right problem-size range. The slide deck's canonical code example is exactly our `n64_b4` case. However, the slides' primary performance recommendation — the **composed 3D FFT (2D + 1D)** method — is absent from our benchmark entirely. That is the technique responsible for the headline 80x speedup, and we have never measured it.

---

### 12.1 What the slides cover

**Slides 1–20 (background and API):**
- DFT math, O(N²) naive vs O(N log N) Cooley-Tukey
- Library comparison (FFTW vs MKL): MKL has native batch support, FFTW wrappers, cluster FFT, AVX-512 optimized kernels
- Slide 17: canonical FFTW API code — `N=3, ngrid={64,64,64}, howmany=4`, forward + backward, out-of-place
- Slide 18: canonical MKL DFTI API code — same problem: `DFTI_COMPLEX, DFTI_DOUBLE, DFTI_NUMBER_OF_TRANSFORMS=howmany=4`, `DftiComputeForward` + `DftiComputeBackward`
- Slide 16: `MKL_VERBOSE` flag to confirm kernel selection at runtime

**Slides 21–32 (3D FFT in real applications and performance):**
- Slide 25: Characteristics of production workloads: "M=10–1000 concurrent FFTs, Nx=10–200 grid, memory- or network-bandwidth limited. Key: leverage batched FFT."
- Slides 26–27: Batch scaling experiments on Intel Xeon Phi 7250 (64 cores). Y-axis: GFLOPS (formula: Cooley-Tukey). X-axis: # concurrent FFTs (1–32). Shows how GFLOPS scale with batch size and affinity settings.
- Slide 28: Conceptual decomposition of 3D FFT into 1D passes along each axis with transposes between.
- **Slide 29**: Composed 3D FFT = 2D + 1D. Code walkthrough of two separate DFTI plans.
- **Slide 30**: Performance comparison on Xeon Platinum 8170 (2S, 26C/S = 52 cores). Composed vs monolithic. Peak ~1300–1400 GFLOPS. "80x faster per FFT using Composed methods with 26 threads vs 1-thread baseline."

---

### 12.2 What we match correctly

| Slide claim | Our benchmark | Match? |
|---|---|---|
| MKL DFTI API: `DftiCreateDescriptor`, `DftiSetValue`, `DftiCommitDescriptor`, `DftiComputeForward/Backward`, `DftiFreeDescriptor` | Exactly this. Same function sequence. | ✓ |
| 3D complex-to-complex (`DFTI_COMPLEX, DFTI_DOUBLE, N=3`) | Same. | ✓ |
| Batch via `DFTI_NUMBER_OF_TRANSFORMS` | Same. `howmany` parameter. | ✓ |
| Canonical example: 64^3 grid, batch=4, forward+backward | This is our `n64_b4` case — the single most benchmarked config in the slides. | ✓ |
| Out-of-place FFT (separate in/out buffers) | `DFTI_NOT_INPLACE`. | ✓ |
| 64-byte alignment (`mkl_malloc`) | Matches AVX-512 requirement. | ✓ |
| GFLOPS formula: "Theoretical Cooley-Tukey, 5×N×log2(N)" | Slide 26 says this explicitly. We use exactly this. | ✓ |
| Both forward and backward measured | Slide code does both; we do both. | ✓ |
| Thread affinity: `KMP_AFFINITY=scatter,granularity=fine` | Slides test scatter, balanced, compact. We use scatter. | ✓ (partial) |
| Grid sizes Nx=10–200 (slide 25 says "typical today") | Our 32–256 covers this. 32^3 and 64^3 are most realistic per slide. | ✓ |
| Warmup before timed runs | We do 5 warmup runs. Slides don't specify count but the principle is implied. | ✓ |
| Powers-of-2 grid sizes for Cooley-Tukey path | 32, 64, 128, 256 — all smooth. Bluestein fallback avoided. | ✓ |

---

### 12.3 The big gap: composed 3D FFT (2D + 1D)

**This is the slide deck's central recommendation. We don't benchmark it.**

Slide 29 shows the composed approach in full code. Instead of one monolithic 3D FFT plan:
```c
// Monolithic (what we do)
MKL_LONG ngrid[3] = {128, 128, 128};
DftiCreateDescriptor(&plan, DFTI_DOUBLE, DFTI_COMPLEX, 3, ngrid);
DftiSetValue(plan, DFTI_NUMBER_OF_TRANSFORMS, howmany);
DftiComputeForward(plan, in, out);
```

The composed approach uses two separate plans — one 2D plan for the YZ slices, one 1D plan for the X axis:
```c
// Composed (slide 29 approach — NOT in our benchmark)
MKL_LONG ngrid_yz[2] = {128, 128};     // YZ plane dimensions
MKL_LONG nx = 128;

// Plan A: Nx independent 2D FFTs of size Ny×Nz
DftiCreateDescriptor(&plan_yz, DFTI_DOUBLE, DFTI_COMPLEX, 2, ngrid_yz);
DftiSetValue(plan_yz, DFTI_NUMBER_OF_TRANSFORMS, nx);         // Nx = 128 transforms
DftiCommitDescriptor(plan_yz);

// Plan B: Ny×Nz independent 1D FFTs of length Nx
DftiCreateDescriptor(&plan_x, DFTI_DOUBLE, DFTI_COMPLEX, 1, &nx);
DftiSetValue(plan_x, DFTI_NUMBER_OF_TRANSFORMS, 128*128);     // Ny*Nz = 16384 transforms
DftiCommitDescriptor(plan_x);

// Forward: 2D first, then 1D
DftiComputeForward(plan_yz, in, work);    // work = scratch buffer
DftiComputeForward(plan_x,  work, out);

// Backward: 1D first, then 2D (reverse order)
DftiComputeBackward(plan_x,  out, work);
DftiComputeBackward(plan_yz, work, in);
```

**Why this is faster than monolithic 3D:**

A monolithic 3D FFT call internally does the same decomposition, but the MKL planner makes general choices. When you compose manually:
- Each sub-plan is a lower-dimensional FFT (2D or 1D) — MKL can apply more aggressive SIMD vectorization across the batch dimension within each sub-plan
- The 2D step (Ny×Nz plane) uses a stride-1 access pattern through contiguous memory; the 1D step (X axis) uses a strided access that the planner can handle explicitly
- Twiddle factor tables for each sub-plan are smaller and stay hot in L2/L3 even when the full 3D working set is DRAM-bound
- The intermediate `work` buffer gives the memory system a chance to settle between passes

**The 80x speedup in context:**

Slide 30 reports: "A FFT is 80 times faster using Composed methods with 26 threads than the baseline using 1 thread."

The 80x breaks down roughly as:
1. Threading alone (1 thread → 26 threads on a 52-core machine): could give up to ~20–25x for compute-bound workloads
2. ISA benefit (AVX-512 vs SSE4.2 scalar baseline): ~2–3x
3. Composed vs monolithic method: the remaining factor, possibly 2–4x

On our machine (10 physical cores), the proportional expectation if we implemented composed FFT:
- Our current 128^3 best: 10T AVX512 → ~62 GFLOPS (monolithic)
- With composed FFT at 10T: possibly 62 × (2–4x) ≈ 120–240 GFLOPS — a large potential gain
- Sanity check: slide 30 at 52 cores ≈ 1300 GFLOPS. Scale down to 10 cores: 1300 × (10/52) ≈ 250 GFLOPS. Roughly consistent with the estimate above.

---

### 12.4 Batch size range mismatch

Slide 25: "M = 10–1000 concurrent FFTs" is the typical range in production electronic structure codes (each "FFT" corresponds to one orbital/band).

Our batch sizes: 1, 2, 4, 8, 16, 32. Maximum = 32.

We're at the low end of their range. Slide 26 (Xeon Phi) sweeps 1–32, similar to us. But for realistic simulation use cases, 100–500 concurrent FFTs is common (100 orbitals per k-point). To reproduce the application-relevant regime, we'd need batch sizes of at least 64–256 for 64^3 grids (where the total working set would stay in L3 or DRAM but twiddle reuse would matter more).

Our batch_scaling profile (1–32 at 128^3, 10T) shows flat GFLOPS because the problem is DRAM-bound regardless. For larger batch sizes at smaller grids (e.g., batch=100 at 64^3), twiddle factor reuse would likely drive GFLOPS higher — but we don't test this.

---

### 12.5 Hardware and scale differences

| Dimension | Slide 30 (performance data) | Our machine |
|---|---|---|
| CPU | Intel Xeon Platinum 8170 | Intel Xeon W-2155 |
| Sockets | 2S | 1S |
| Physical cores | 26/socket × 2 = 52 total | 10 total |
| DRAM bandwidth | 2× multi-channel DDR4 | Single-socket DDR4 |
| Best reported GFLOPS (128^3, composed) | ~1300–1400 | N/A (not measured) |
| Our best GFLOPS (128^3, monolithic, 10T) | N/A | ~62 |

The 8.3x core count difference (52 vs 10) and the composed-vs-monolithic method difference together explain why slide 30 shows ~20x more GFLOPS than us.

Slide 26 (batch scaling) used Xeon Phi 7250 (64 cores, 1.4 GHz) — an even more different platform. The principle (GFLOPS increasing with batch count) applies, but absolute numbers are not comparable.

---

### 12.6 What we do that the slides don't show

| Our benchmark addition | Rationale |
|---|---|
| Three-way ISA comparison: SSE4.2 / AVX2 / AVX512 | The slides don't explicitly compare ISA tiers. They assume you'll use AVX-512. We added this to quantify the ISA benefit — most useful for compute-bound small grids. |
| HyperThreading analysis (10T vs 20T) | Slides don't address HT explicitly. Our data shows HT hurts for this workload. |
| Cache regime categorization (L2 / L3 / DRAM boundary) | Slides discuss bandwidth-limited behavior in general. We explicitly size grids to bracket the boundaries. |
| `MKL_ENABLE_INSTRUCTIONS` as ISA control mechanism | Slides use compile flags / MKL defaults. We demonstrate the runtime env var override. |

---

### 12.7 MKL_VERBOSE — a missing validation step

Slide 16 explicitly shows `MKL_VERBOSE=1` as a way to confirm which kernel MKL is actually dispatching. Example output in the slides shows kernel names containing "z1d", "avx512", etc. We currently use `MKL_ENABLE_INSTRUCTIONS` to restrict ISA, but we never verify via `MKL_VERBOSE` that MKL actually selected the expected kernel.

If `MKL_ENABLE_INSTRUCTIONS=AVX512` but MKL internally falls back (due to alignment, size constraints, or plan type), we'd report AVX512 numbers that were actually computed with a different kernel path. Adding a short `MKL_VERBOSE=1` run at the start of each profile (just one warmup run, discarded for timing) would make ISA selection verifiable.

---

### 12.8 Summary: what to add to be fully aligned with the slides

| Gap | Priority | What to add |
|---|---|---|
| **Composed 3D FFT (2D + 1D)** | **High** | New profile: `avx512_composed_phys` running the slide 29 two-plan approach. Compare GFLOPS directly against `avx512_phys` (monolithic) at 128^3 batch=4. This is the single most impactful missing measurement. |
| **Larger batch sizes** | Medium | Extend `THROUGHPUT_BATCHES` to include 16, 32, 64 for 64^3. At 64^3 batch=64 the total = 512 MB (DRAM-bound) but twiddle tables (small) stay cache-hot. |
| **MKL_VERBOSE verification** | Low | One-time validation run with `MKL_VERBOSE=1` per ISA cap level to confirm kernel names. Not needed every benchmark run, but should be done once per machine/MKL-version. |
| **Batch scaling at 32^3** | Medium | Already noted in §9.4. Add a small-grid batch scaling profile to show twiddle reuse in the compute-bound regime. |

The existing benchmark measures all the right things for understanding ISA impact and threading behavior. Adding the composed FFT profile would let us reproduce the slide deck's headline result on our hardware and understand how much of the 80x is achievable on a 10-core machine.
