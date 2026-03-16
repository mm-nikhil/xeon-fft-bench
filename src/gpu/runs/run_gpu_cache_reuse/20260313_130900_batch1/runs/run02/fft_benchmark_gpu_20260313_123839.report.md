# GPU FFT Run Report

- Generated at: 2026-03-13 12:38:44.159451
- Source log: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run02/fft_benchmark_gpu_20260313_123839.log`
- Profile: `gpu_cache_reuse`
- Description: cuFFT cache-reuse (hot device-buffer reuse)
- Workload: `throughput`
- Family: `run_gpu_cache_reuse`

## Config

- `BENCH_MAX_ADAPT_ITERS` = `100000000`
- `BENCH_MAX_MEM_MB` = `8192`
- `BENCH_MIN_TOTAL_MS` = `50`
- `BENCH_NRUNS` = `20`
- `BENCH_STREAM_MAX_SLOTS` = `1`
- `BENCH_STREAM_MIN_SLOTS` = `1`
- `BENCH_STREAM_MODE` = `0`
- `BENCH_STREAM_TARGET_MB` = `0`
- `BENCH_VALIDATE` = `1`
- `BENCH_VALIDATE_STRICT` = `1`
- `BENCH_VALIDATE_TOL` = `1e-4`
- `BENCH_WARMUP` = `5`
- `THROUGHPUT_BATCHES` = `1`
- `THROUGHPUT_LENGTHS` = `2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536`

## Results

| Case | N | Batch | ThreadsField | Status | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Slots | Work MB | Validation | Note |
|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| n2_b1 | 2 | 1 | 1 | ok | 0.001795 | 0.005571 | 0.001773 | 0.005640 | 0.00 | 1 | 0.00 | PASS | - |
| n4_b1 | 4 | 1 | 1 | ok | 0.001786 | 0.022399 | 0.001777 | 0.022513 | 0.00 | 1 | 0.00 | PASS | - |
| n8_b1 | 8 | 1 | 1 | ok | 0.001795 | 0.066841 | 0.001796 | 0.066823 | 0.00 | 1 | 0.00 | PASS | - |
| n16_b1 | 16 | 1 | 1 | ok | 0.001812 | 0.176614 | 0.001815 | 0.176289 | 0.00 | 1 | 0.00 | PASS | - |
| n32_b1 | 32 | 1 | 1 | ok | 0.002033 | 0.393576 | 0.002032 | 0.393688 | 0.00 | 1 | 0.00 | PASS | - |
| n64_b1 | 64 | 1 | 1 | ok | 0.002029 | 0.946454 | 0.002029 | 0.946484 | 0.00 | 1 | 0.00 | PASS | - |
| n128_b1 | 128 | 1 | 1 | ok | 0.002172 | 2.062385 | 0.002172 | 2.062430 | 0.00 | 1 | 0.00 | PASS | - |
| n256_b1 | 256 | 1 | 1 | ok | 0.002313 | 4.427901 | 0.002313 | 4.427881 | 0.01 | 1 | 0.00 | PASS | - |
| n512_b1 | 512 | 1 | 1 | ok | 0.002598 | 8.868404 | 0.002598 | 8.868495 | 0.02 | 1 | 0.00 | PASS | - |
| n1024_b1 | 1024 | 1 | 1 | ok | 0.002881 | 17.769814 | 0.002882 | 17.766447 | 0.03 | 1 | 0.01 | PASS | - |
| n2048_b1 | 2048 | 1 | 1 | ok | 0.003723 | 30.256588 | 0.003733 | 30.177968 | 0.06 | 1 | 0.02 | PASS | - |
| n4096_b1 | 4096 | 1 | 1 | ok | 0.004159 | 59.096884 | 0.004159 | 59.095676 | 0.12 | 1 | 0.03 | PASS | - |
| n8192_b1 | 8192 | 1 | 1 | ok | 0.007141 | 74.571798 | 0.007141 | 74.565689 | 0.25 | 1 | 0.06 | PASS | - |
| n16384_b1 | 16384 | 1 | 1 | ok | 0.008897 | 128.901553 | 0.008897 | 128.907001 | 0.50 | 1 | 0.12 | PASS | - |
| n32768_b1 | 32768 | 1 | 1 | ok | 0.007058 | 348.192118 | 0.007058 | 348.221410 | 1.00 | 1 | 0.25 | PASS | - |
| n65536_b1 | 65536 | 1 | 1 | ok | 0.006424 | 816.110393 | 0.006435 | 814.690722 | 2.00 | 1 | 0.50 | PASS | - |

- Status counts: {'ok': 16}