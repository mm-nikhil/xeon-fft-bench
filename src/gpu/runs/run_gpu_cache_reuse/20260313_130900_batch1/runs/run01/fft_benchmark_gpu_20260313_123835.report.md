# GPU FFT Run Report

- Generated at: 2026-03-13 12:38:39.773542
- Source log: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run01/fft_benchmark_gpu_20260313_123835.log`
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
| n2_b1 | 2 | 1 | 1 | ok | 0.001817 | 0.005503 | 0.001794 | 0.005574 | 0.00 | 1 | 0.00 | PASS | - |
| n4_b1 | 4 | 1 | 1 | ok | 0.001802 | 0.022192 | 0.001769 | 0.022606 | 0.00 | 1 | 0.00 | PASS | - |
| n8_b1 | 8 | 1 | 1 | ok | 0.001783 | 0.067295 | 0.001780 | 0.067429 | 0.00 | 1 | 0.00 | PASS | - |
| n16_b1 | 16 | 1 | 1 | ok | 0.001801 | 0.177633 | 0.001800 | 0.177804 | 0.00 | 1 | 0.00 | PASS | - |
| n32_b1 | 32 | 1 | 1 | ok | 0.002018 | 0.396496 | 0.002016 | 0.396815 | 0.00 | 1 | 0.00 | PASS | - |
| n64_b1 | 64 | 1 | 1 | ok | 0.002011 | 0.954702 | 0.002011 | 0.954798 | 0.00 | 1 | 0.00 | PASS | - |
| n128_b1 | 128 | 1 | 1 | ok | 0.002153 | 2.080356 | 0.002154 | 2.080262 | 0.00 | 1 | 0.00 | PASS | - |
| n256_b1 | 256 | 1 | 1 | ok | 0.002293 | 4.466220 | 0.002293 | 4.465994 | 0.01 | 1 | 0.00 | PASS | - |
| n512_b1 | 512 | 1 | 1 | ok | 0.002576 | 8.945273 | 0.002576 | 8.945722 | 0.02 | 1 | 0.00 | PASS | - |
| n1024_b1 | 1024 | 1 | 1 | ok | 0.002856 | 17.924432 | 0.002857 | 17.921818 | 0.03 | 1 | 0.01 | PASS | - |
| n2048_b1 | 2048 | 1 | 1 | ok | 0.003696 | 30.472435 | 0.003700 | 30.439885 | 0.06 | 1 | 0.02 | PASS | - |
| n4096_b1 | 4096 | 1 | 1 | ok | 0.004123 | 59.606816 | 0.004123 | 59.608035 | 0.12 | 1 | 0.03 | PASS | - |
| n8192_b1 | 8192 | 1 | 1 | ok | 0.007079 | 75.218187 | 0.007083 | 75.181492 | 0.25 | 1 | 0.06 | PASS | - |
| n16384_b1 | 16384 | 1 | 1 | ok | 0.008821 | 130.018028 | 0.008827 | 129.924495 | 0.50 | 1 | 0.12 | PASS | - |
| n32768_b1 | 32768 | 1 | 1 | ok | 0.007059 | 348.171500 | 0.007058 | 348.214955 | 1.00 | 1 | 0.25 | PASS | - |
| n65536_b1 | 65536 | 1 | 1 | ok | 0.006432 | 815.147303 | 0.006437 | 814.528809 | 2.00 | 1 | 0.50 | PASS | - |

- Status counts: {'ok': 16}