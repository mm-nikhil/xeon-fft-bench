# 1D GPU FFT Benchmark: Companion Review

This note is intended to be read with `claude_review.md`. The shared benchmark structure, FLOP model, validation philosophy, and hot/cold rationale are the same unless stated otherwise below, so they are not repeated here in full.

**Platform:** NVIDIA GeForce RTX 3080 (GA102, Ampere, LHR)  
**Library:** cuFFT via CUDA toolkit 11.5 (`nvcc` `V11.5.119`)  
**Precision:** Single-precision complex (`cufftComplex`, 8 bytes/element)  
**Date:** 2026-03-16

---

## 8. Comparison with Xeon FFT Benchmark

The GPU benchmark used for Xeon comparison is the device-resident setup:

- `cache_reuse` / hot: same device buffer reused every timed iteration
- `cache_noreuse` / cold-streaming: slot rotation over a larger device-resident working set
- `batch_1`: intended extra-cold single-FFT campaign

This is the correct analogue of the Xeon benchmark. On Xeon, the timed region is the FFT call on host-resident RAM. On GPU, the timed region is the FFT call on device-resident VRAM.

### 8.1 Current Safe GPU Evidence

Safe device-resident sessions:

- `src/gpu/runs/run_gpu_cache_reuse/20260313_130500/`
- `src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/`
- `src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/` (diagnostic subset only)

Legacy outputs under `src/gpu/fft_logs/`, `src/gpu/plots/out/`, and `src/gpu/runs/older_run/` remain historical only and should not be mixed into current claims.

### 8.2 Best Forward Throughput in Safe GPU Runs

| Campaign | Memory mode | Best case | GFLOPS | % of 36817.92 peak |
|---|---|---|---:|---:|
| `run_gpu_cache_reuse` | Hot device-buffer reuse | N=16384, B=1024 | 2798.54 | 7.60% |
| `run_gpu_cache_noreuse` | Moderate cold, 128 MB target | N=16384, B=1024 | 2792.43 | 7.58% |
| `run_gpu_cache_reuse/130900_batch1` | Hot batch=1 diagnostic | N=65536, B=1 | 815.17 | 2.21% |
| `run_gpu_batch_1` | Extra-cold batch=1 | Not yet executed | - | - |

- Mean hot/cold ratio across 96 matched cases: `1.169x`
- Median hot/cold ratio: `1.152x`
- Mean ratio for `N >= 4096`: `1.055x`

This is much narrower than the Xeon hot/cold gap, but it is still a real locality effect on the GPU. Large cuFFT workloads behave more like a device-memory and staging problem than a cache-hot vs. DRAM-cold collapse.

### 8.3 Matched-Case Example

At `N=65536, batch=1`:

| Campaign | Working set | GFLOPS | Drop vs. reuse |
|---|---|---:|---:|---:|
| `run_gpu_cache_reuse` | ~2.0 MB | 723.06 | - |
| `run_gpu_cache_noreuse` | ~129.0 MB | 640.50 | -11.4% |

This is directionally similar to Xeon, but the drop is much smaller. For the GPU, cold mode mainly removes locality within device memory; it does not add PCIe transfer into the timed region.

### 8.4 Plots

All current GPU families, including the new E2E families, generate the same run-local 3-plot pack:

1. `plots/master/all_cases_master.png`
   Forward GFLOPS, forward latency, and working-set heatmaps across the full `N x batch` matrix.
2. `plots/n-wise/nwise_all_lengths_compact.png`
   One panel per FFT length, showing throughput vs. batch.
3. `plots/line_by_batch/line_by_batch_all_batches_compact.png`
   One panel per batch, showing throughput vs. FFT length.

The new E2E sessions also pass the same plot contract and coverage checks as the earlier GPU families.

---

## 9. GPU Hardware and System Configuration

### 9.1 GPU Specifications

These values were checked on this machine with `nvidia-smi`, `nvidia-smi -q`, and `lspci`.

| Parameter | Value |
|---|---|
| Model | NVIDIA GeForce RTX 3080 |
| PCI ID | GA102 `[10de:2216]` |
| Board variant | GeForce RTX 3080 Lite Hash Rate |
| Architecture | Ampere |
| Product brand | GeForce |
| Compute capability | 8.6 |
| SM count | 68 |
| CUDA cores / SM | 128 |
| Total CUDA cores | 8704 |
| Warp size | 32 |
| Max resident threads / SM | 1536 |
| Max resident threads / device | 104448 |
| Max threads / block | 1024 |
| PCIe link | Gen4 x16 |
| Bus ID | `00000000:08:00.0` |
| VBIOS | `94.02.71.40.83` |
| GPU UUID | `GPU-e896d2e8-8863-85f4-a931-7b2fe717a506` |

### 9.2 Memory and Power

| Parameter | Value |
|---|---|
| Installed VRAM | 10 GB |
| Memory type | GDDR6X |
| Memory interface | 320-bit |
| Max memory clock reported locally | 9501 MHz |
| Derived peak memory bandwidth | ~760.1 GB/s |
| Default board power limit | 320 W |
| Max board power limit | 336 W |
| GPU target temperature | 83 C |
| Max operating temperature | 93 C |
| Slowdown temperature | 95 C |
| Shutdown temperature | 98 C |
| ECC | N/A on this GeForce board |

Bandwidth is derived from the local max memory clock and the RTX 3080 320-bit memory interface:

```text
Bandwidth ~= 9501 MHz x 2 x 320 / 8
          ~= 760.1 GB/s
```

### 9.3 Software Environment

| Component | Value |
|---|---|
| OS | Linux 6.8.0-90-generic x86_64 GNU/Linux |
| NVIDIA driver | 580.126.09 |
| Driver-reported CUDA version | 13.0 |
| CUDA compiler | `nvcc` release 11.5, `V11.5.119` |
| Host compiler | `g++ 10.5.0` |
| FFT library | cuFFT |

### 9.4 Theoretical Compute Peak

The report builder uses:

```text
Peak SP GFLOPS = CUDA cores x 2 FLOP/cycle x max SM clock
               = 8704 x 2 x 2.115
               = 36817.92 SP GFLOPS
```

As with the Xeon review, this is a compute roofline, not a realistic FFT roofline. FFT remains dominated by data movement and staging, so single-digit percent-of-peak values are expected.

---

## 10. GPU Benchmark Notes

For shared benchmark logic, use the Xeon review. The GPU-specific differences are:

1. **cuFFT algorithm choice is internal.** Similar to MKL DFTI, cuFFT does not expose one fixed FFT kernel choice. The selected execution path depends on `N`, batch, precision, placement, and GPU architecture.
2. **Timing is done with CUDA events.** For the GPU/Xeon comparison setup, the benchmark measures repeated `cufftExecC2C` calls only.
3. **Workspace is explicit.** cuFFT auto-allocation is disabled, workspace is queried and allocated explicitly, and that workspace is reported.
4. **Cold mode is slot rotation in device memory.** This defeats immediate reuse of device-resident tensors; it does not simulate a PCIe-cold end-to-end pipeline.
5. **The same algorithmic FLOP model as Xeon is used.**

```text
FLOPs = 5 x N x log2(N) x batch
SP GFLOPS = FLOPs / (avg_ms x 1e6)
```

6. **The safe GPU harness for Xeon comparison is the streaming harness.**

- Device-resident harness: `src/gpu/runs/common/fft_benchmark_gpu_streaming.cu`
- Safe family runners:
  - `src/gpu/runs/run_gpu_cache_reuse/tools/run_run_gpu_cache_reuse_suite.sh`
  - `src/gpu/runs/run_gpu_cache_noreuse/tools/run_run_gpu_cache_noreuse_suite.sh`
  - `src/gpu/runs/run_gpu_batch_1/tools/run_run_gpu_batch_1_suite.sh`
- Legacy generic harness kept only for history:
  - `src/gpu/fft_benchmark.cu`
  - `src/gpu/run_fft_benchmarks.sh`

### 10.1 Practical Pairing with Xeon

For CPU/GPU comparison, the fair pairings are:

- Xeon `run_cache_reuse` vs. GPU `run_gpu_cache_reuse`
- Xeon `run_cache_noreuse` vs. GPU `run_gpu_cache_noreuse`
- Xeon `run_batch_1` vs. GPU `run_gpu_batch_1` once the GPU batch-1 family is actually run

The hot/hot comparison is methodologically clean now. The cold/cold comparison is also valid in intent, but still slightly harsher on the GPU for very small `N` because the GPU no-reuse runner can fill the 128 MB target more aggressively than the current Xeon no-reuse runner.

### 10.2 Bottom Line

The GPU benchmark is now consistent enough with the Xeon framework for defensible comparison, with one key interpretation rule:

- Xeon cold mode is mostly about defeating CPU cache residency.
- GPU cold mode is mostly about defeating device-memory locality and exposing workspace pressure.

For current claims, use:

- `run_gpu_cache_reuse/20260313_130500` for the GPU device-resident hot upper bound
- `run_gpu_cache_noreuse/20260313_121932` for the GPU sustained device-resident comparison
- `run_gpu_cache_reuse/20260313_130900_batch1` only as a diagnostic subset, not as the true GPU counterpart to Xeon `run_batch_1`

## 11. Appendix: End-to-End PCIe GPU Runs

This section is intentionally separate from the main GPU/Xeon comparison because it is not the Xeon analogue.

### 11.1 What the E2E Setup Measures

The new E2E families measure:

1. host-to-device copy
2. cuFFT
3. device-to-host copy

on every timed iteration.

So these runs answer a different question:

- not "how fast is cuFFT on GPU-resident data?"
- but "how fast is the full host-to-host GPU FFT path when PCIe transfer is included?"

### 11.2 E2E Families

- `src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/`
- `src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/`

The E2E harness uses pinned host memory and the timed region is `H2D + cuFFT + D2H`.

### 11.3 E2E Results

| Campaign | Best case | GFLOPS | % of 36817.92 peak |
|---|---|---:|---:|
| `run_gpu_e2e_reuse` | N=65536, B=256 | 120.37 | 0.33% |
| `run_gpu_e2e_noreuse` | N=65536, B=150 | 118.52 | 0.32% |

Matched-case behavior is very different from the device-resident runs:

- Mean reuse/no-reuse ratio across 96 matched cases: `1.011x`
- Median reuse/no-reuse ratio: `1.013x`
- Mean ratio for `N >= 4096`: `1.020x`

At `N=65536, batch=1`:

| Campaign | Working set | GFLOPS | Drop vs. reuse |
|---|---:|---:|---:|
| `run_gpu_e2e_reuse` | ~2.5 MB | 83.97 | - |
| `run_gpu_e2e_noreuse` | ~256.5 MB | 81.68 | -2.7% |

### 11.4 Why E2E Reuse and No-Reuse Are So Similar

This is expected.

Once PCIe transfer is included, both modes pay almost the same dominant cost:

- same bytes copied H2D
- same bytes copied D2H
- same FFT work

So even though no-reuse rotates a much larger host+device slot pool, the total time is still dominated by transfer and staging, not by locality alone. That is why E2E reuse and no-reuse converge much more than the device-resident GPU runs.
