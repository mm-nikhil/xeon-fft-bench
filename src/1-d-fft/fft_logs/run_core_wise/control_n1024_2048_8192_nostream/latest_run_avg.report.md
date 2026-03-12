# 1D FFT run_core_wise (1-run average, forward-focused, extra-cold streaming)

- Generated at: Tue Mar 10 12:02:43 IST 2026
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_core_wise/control_n1024_2048_8192_nostream/manifest.tsv`
- Runs combined: 1
- Forward-only reporting: yes
- Matrix scope: batch fixed to 1, N=2..4194304 (doubling), cores=1..10, threads={cores, 2xcores}

## Server Hardware

- CPU: Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz (family 6, model 85)
- Physical cores: 10, Logical threads: 20 (HT: 2 threads/core)
- Base clock: 3.30 GHz | Max turbo: 4.5 GHz
- NUMA nodes: 1

## Peak Model

- SP peak formula: cores x 2 FMA/core x 16 lanes x 2 FLOP/FMA x freq
- Report denominator for %peak: 2112.0 SP GFLOPS

## Correctness Summary

- CHECK lines counted: 0
- CHECK failures: 0
- Missing CHECK samples: 60
- Strict validation required at runtime: yes

## Data Quality

- Averaged rows: 60
- Rows with incomplete quality: 60
- Expected samples per row: 1

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_core_wise/control_n1024_2048_8192_nostream/runs/run01/fft_benchmark_20260310_120223.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_core_wise/control_n1024_2048_8192_nostream/runs/run01/fft_benchmark_20260310_120223.report.md` |

## Scenario Catalog

| Profile | Description | Workload | ISA | Cores | Threads/Core | Threads | CPU Set |
|---|---|---|---|---:|---:|---:|---|
| avx512_c01_t01 | MKL AVX-512 pinned to 1 core(s), 1 thread(s) | throughput | AVX512 | 1 | 1 | 1 | `0` |
| avx512_c01_t02 | MKL AVX-512 pinned to 1 core(s), 2 thread(s) | throughput | AVX512 | 1 | 2 | 2 | `0,10` |
| avx512_c02_t02 | MKL AVX-512 pinned to 2 core(s), 2 thread(s) | throughput | AVX512 | 2 | 1 | 2 | `0,1` |
| avx512_c02_t04 | MKL AVX-512 pinned to 2 core(s), 4 thread(s) | throughput | AVX512 | 2 | 2 | 4 | `0,1,10,11` |
| avx512_c03_t03 | MKL AVX-512 pinned to 3 core(s), 3 thread(s) | throughput | AVX512 | 3 | 1 | 3 | `0,1,2` |
| avx512_c03_t06 | MKL AVX-512 pinned to 3 core(s), 6 thread(s) | throughput | AVX512 | 3 | 2 | 6 | `0,1,2,10,11,12` |
| avx512_c04_t04 | MKL AVX-512 pinned to 4 core(s), 4 thread(s) | throughput | AVX512 | 4 | 1 | 4 | `0,1,2,3` |
| avx512_c04_t08 | MKL AVX-512 pinned to 4 core(s), 8 thread(s) | throughput | AVX512 | 4 | 2 | 8 | `0,1,2,3,10,11,12,13` |
| avx512_c05_t05 | MKL AVX-512 pinned to 5 core(s), 5 thread(s) | throughput | AVX512 | 5 | 1 | 5 | `0,1,2,3,4` |
| avx512_c05_t10 | MKL AVX-512 pinned to 5 core(s), 10 thread(s) | throughput | AVX512 | 5 | 2 | 10 | `0,1,2,3,4,10,11,12,13,14` |
| avx512_c06_t06 | MKL AVX-512 pinned to 6 core(s), 6 thread(s) | throughput | AVX512 | 6 | 1 | 6 | `0,1,2,3,4,5` |
| avx512_c06_t12 | MKL AVX-512 pinned to 6 core(s), 12 thread(s) | throughput | AVX512 | 6 | 2 | 12 | `0,1,2,3,4,5,10,11,12,13,14,15` |
| avx512_c07_t07 | MKL AVX-512 pinned to 7 core(s), 7 thread(s) | throughput | AVX512 | 7 | 1 | 7 | `0,1,2,3,4,5,6` |
| avx512_c07_t14 | MKL AVX-512 pinned to 7 core(s), 14 thread(s) | throughput | AVX512 | 7 | 2 | 14 | `0,1,2,3,4,5,6,10,11,12,13,14,15,16` |
| avx512_c08_t08 | MKL AVX-512 pinned to 8 core(s), 8 thread(s) | throughput | AVX512 | 8 | 1 | 8 | `0,1,2,3,4,5,6,7` |
| avx512_c08_t16 | MKL AVX-512 pinned to 8 core(s), 16 thread(s) | throughput | AVX512 | 8 | 2 | 16 | `0,1,2,3,4,5,6,7,10,11,12,13,14,15,16,17` |
| avx512_c09_t09 | MKL AVX-512 pinned to 9 core(s), 9 thread(s) | throughput | AVX512 | 9 | 1 | 9 | `0,1,2,3,4,5,6,7,8` |
| avx512_c09_t18 | MKL AVX-512 pinned to 9 core(s), 18 thread(s) | throughput | AVX512 | 9 | 2 | 18 | `0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18` |
| avx512_c10_t10 | MKL AVX-512 pinned to 10 core(s), 10 thread(s) | throughput | AVX512 | 10 | 1 | 10 | `0,1,2,3,4,5,6,7,8,9` |
| avx512_c10_t20 | MKL AVX-512 pinned to 10 core(s), 20 thread(s) | throughput | AVX512 | 10 | 2 | 20 | `0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19` |

## Top 15 Forward Cases

| Workload | Case | N | Batch | Cores | Threads/Core | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Fwd % Peak | Speedup vs c01/t01 | Samples |
|---|---|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---|
| throughput | n1024_b1 | 1024 | 1 | 5 | 2 | 10 | avx512_c05_t10 | 0.000517 | 99.03 | 4.69% | 1.1412 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 2 | 1 | 2 | avx512_c02_t02 | 0.000524 | 97.71 | 4.63% | 1.1260 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 6 | 2 | 12 | avx512_c06_t12 | 0.000527 | 97.15 | 4.60% | 1.1195 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 8 | 1 | 8 | avx512_c08_t08 | 0.000528 | 96.97 | 4.59% | 1.1174 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 6 | 1 | 6 | avx512_c06_t06 | 0.000533 | 96.06 | 4.55% | 1.1069 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 4 | 1 | 4 | avx512_c04_t04 | 0.000538 | 95.17 | 4.51% | 1.0967 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 7 | 2 | 14 | avx512_c07_t14 | 0.000539 | 94.99 | 4.50% | 1.0946 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 8 | 2 | 16 | avx512_c08_t16 | 0.000540 | 94.81 | 4.49% | 1.0926 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 3 | 2 | 6 | avx512_c03_t06 | 0.000541 | 94.64 | 4.48% | 1.0906 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 7 | 1 | 7 | avx512_c07_t07 | 0.000550 | 93.09 | 4.41% | 1.0727 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 3 | 1 | 3 | avx512_c03_t03 | 0.000555 | 92.25 | 4.37% | 1.0631 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 4 | 2 | 8 | avx512_c04_t08 | 0.000555 | 92.25 | 4.37% | 1.0631 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 9 | 2 | 18 | avx512_c09_t18 | 0.000559 | 91.59 | 4.34% | 1.0555 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 5 | 1 | 5 | avx512_c05_t05 | 0.000564 | 90.78 | 4.30% | 1.0461 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 10 | 1 | 10 | avx512_c10_t10 | 0.000566 | 90.46 | 4.28% | 1.0424 | 1/1 |

## Averaged Results (Forward)

| Workload | Case | N | Batch | Cores | Threads/Core | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Mem MB | Fwd % Peak | Speedup vs c01/t01 | Samples | Check (ok/fail) | Quality |
|---|---|---:|---:|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---|---|---|
| throughput | n1024_b1 | 1024 | 1 | 1 | 1 | 1 | avx512_c01_t01 | AVX512 | 0.000590 | 86.78 | 0.0200 | 4.11% | 1.0000 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 1 | 2 | 2 | avx512_c01_t02 | AVX512 | 0.000569 | 89.98 | 0.0200 | 4.26% | 1.0369 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 2 | 1 | 2 | avx512_c02_t02 | AVX512 | 0.000524 | 97.71 | 0.0200 | 4.63% | 1.1260 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 2 | 2 | 4 | avx512_c02_t04 | AVX512 | 0.000592 | 86.49 | 0.0200 | 4.09% | 0.9966 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 3 | 1 | 3 | avx512_c03_t03 | AVX512 | 0.000555 | 92.25 | 0.0200 | 4.37% | 1.0631 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 3 | 2 | 6 | avx512_c03_t06 | AVX512 | 0.000541 | 94.64 | 0.0200 | 4.48% | 1.0906 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 4 | 1 | 4 | avx512_c04_t04 | AVX512 | 0.000538 | 95.17 | 0.0200 | 4.51% | 1.0967 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 4 | 2 | 8 | avx512_c04_t08 | AVX512 | 0.000555 | 92.25 | 0.0200 | 4.37% | 1.0631 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 5 | 1 | 5 | avx512_c05_t05 | AVX512 | 0.000564 | 90.78 | 0.0200 | 4.30% | 1.0461 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 5 | 2 | 10 | avx512_c05_t10 | AVX512 | 0.000517 | 99.03 | 0.0200 | 4.69% | 1.1412 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 6 | 1 | 6 | avx512_c06_t06 | AVX512 | 0.000533 | 96.06 | 0.0200 | 4.55% | 1.1069 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 6 | 2 | 12 | avx512_c06_t12 | AVX512 | 0.000527 | 97.15 | 0.0200 | 4.60% | 1.1195 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 7 | 1 | 7 | avx512_c07_t07 | AVX512 | 0.000550 | 93.09 | 0.0200 | 4.41% | 1.0727 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 7 | 2 | 14 | avx512_c07_t14 | AVX512 | 0.000539 | 94.99 | 0.0200 | 4.50% | 1.0946 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 8 | 1 | 8 | avx512_c08_t08 | AVX512 | 0.000528 | 96.97 | 0.0200 | 4.59% | 1.1174 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 8 | 2 | 16 | avx512_c08_t16 | AVX512 | 0.000540 | 94.81 | 0.0200 | 4.49% | 1.0926 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 9 | 1 | 9 | avx512_c09_t09 | AVX512 | 0.000605 | 84.63 | 0.0200 | 4.01% | 0.9752 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 9 | 2 | 18 | avx512_c09_t18 | AVX512 | 0.000559 | 91.59 | 0.0200 | 4.34% | 1.0555 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 10 | 1 | 10 | avx512_c10_t10 | AVX512 | 0.000566 | 90.46 | 0.0200 | 4.28% | 1.0424 | 1/1 | 0/0 | incomplete |
| throughput | n1024_b1 | 1024 | 1 | 10 | 2 | 20 | avx512_c10_t20 | AVX512 | 0.000593 | 86.34 | 0.0200 | 4.09% | 0.9949 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 1 | 1 | 1 | avx512_c01_t01 | AVX512 | 0.001453 | 77.52 | 0.0500 | 3.67% | 1.0000 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 1 | 2 | 2 | avx512_c01_t02 | AVX512 | 0.001390 | 81.04 | 0.0500 | 3.84% | 1.0453 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 2 | 1 | 2 | avx512_c02_t02 | AVX512 | 0.001384 | 81.39 | 0.0500 | 3.85% | 1.0499 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 2 | 2 | 4 | avx512_c02_t04 | AVX512 | 0.001502 | 74.99 | 0.0500 | 3.55% | 0.9674 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 3 | 1 | 3 | avx512_c03_t03 | AVX512 | 0.001549 | 72.72 | 0.0500 | 3.44% | 0.9380 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 3 | 2 | 6 | avx512_c03_t06 | AVX512 | 0.001388 | 81.15 | 0.0500 | 3.84% | 1.0468 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 4 | 1 | 4 | avx512_c04_t04 | AVX512 | 0.001402 | 80.34 | 0.0500 | 3.80% | 1.0364 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 4 | 2 | 8 | avx512_c04_t08 | AVX512 | 0.001403 | 80.29 | 0.0500 | 3.80% | 1.0356 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 5 | 1 | 5 | avx512_c05_t05 | AVX512 | 0.001395 | 80.75 | 0.0500 | 3.82% | 1.0416 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 5 | 2 | 10 | avx512_c05_t10 | AVX512 | 0.001364 | 82.58 | 0.0500 | 3.91% | 1.0652 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 6 | 1 | 6 | avx512_c06_t06 | AVX512 | 0.001335 | 84.37 | 0.0500 | 4.00% | 1.0884 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 6 | 2 | 12 | avx512_c06_t12 | AVX512 | 0.001388 | 81.15 | 0.0500 | 3.84% | 1.0468 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 7 | 1 | 7 | avx512_c07_t07 | AVX512 | 0.001384 | 81.39 | 0.0500 | 3.85% | 1.0499 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 7 | 2 | 14 | avx512_c07_t14 | AVX512 | 0.001387 | 81.21 | 0.0500 | 3.85% | 1.0476 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 8 | 1 | 8 | avx512_c08_t08 | AVX512 | 0.001350 | 83.44 | 0.0500 | 3.95% | 1.0763 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 8 | 2 | 16 | avx512_c08_t16 | AVX512 | 0.001413 | 79.72 | 0.0500 | 3.77% | 1.0283 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 9 | 1 | 9 | avx512_c09_t09 | AVX512 | 0.001438 | 78.33 | 0.0500 | 3.71% | 1.0104 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 9 | 2 | 18 | avx512_c09_t18 | AVX512 | 0.001398 | 80.57 | 0.0500 | 3.81% | 1.0393 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 10 | 1 | 10 | avx512_c10_t10 | AVX512 | 0.001418 | 79.44 | 0.0500 | 3.76% | 1.0247 | 1/1 | 0/0 | incomplete |
| throughput | n2048_b1 | 2048 | 1 | 10 | 2 | 20 | avx512_c10_t20 | AVX512 | 0.001496 | 75.29 | 0.0500 | 3.57% | 0.9713 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 1 | 1 | 1 | avx512_c01_t01 | AVX512 | 0.008023 | 66.37 | 0.1900 | 3.14% | 1.0000 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 1 | 2 | 2 | avx512_c01_t02 | AVX512 | 0.014938 | 35.65 | 0.1900 | 1.69% | 0.5371 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 2 | 1 | 2 | avx512_c02_t02 | AVX512 | 0.014293 | 37.25 | 0.1900 | 1.76% | 0.5613 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 2 | 2 | 4 | avx512_c02_t04 | AVX512 | 0.013081 | 40.71 | 0.1900 | 1.93% | 0.6133 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 3 | 1 | 3 | avx512_c03_t03 | AVX512 | 0.011268 | 47.26 | 0.1900 | 2.24% | 0.7120 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 3 | 2 | 6 | avx512_c03_t06 | AVX512 | 0.012610 | 42.23 | 0.1900 | 2.00% | 0.6362 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 4 | 1 | 4 | avx512_c04_t04 | AVX512 | 0.009009 | 59.11 | 0.1900 | 2.80% | 0.8906 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 4 | 2 | 8 | avx512_c04_t08 | AVX512 | 0.009986 | 53.32 | 0.1900 | 2.52% | 0.8034 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 5 | 1 | 5 | avx512_c05_t05 | AVX512 | 0.009274 | 57.42 | 0.1900 | 2.72% | 0.8651 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 5 | 2 | 10 | avx512_c05_t10 | AVX512 | 0.010359 | 51.40 | 0.1900 | 2.43% | 0.7745 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 6 | 1 | 6 | avx512_c06_t06 | AVX512 | 0.009415 | 56.56 | 0.1900 | 2.68% | 0.8522 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 6 | 2 | 12 | avx512_c06_t12 | AVX512 | 0.010201 | 52.20 | 0.1900 | 2.47% | 0.7865 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 7 | 1 | 7 | avx512_c07_t07 | AVX512 | 0.009621 | 55.35 | 0.1900 | 2.62% | 0.8339 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 7 | 2 | 14 | avx512_c07_t14 | AVX512 | 0.009724 | 54.76 | 0.1900 | 2.59% | 0.8251 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 8 | 1 | 8 | avx512_c08_t08 | AVX512 | 0.008704 | 61.18 | 0.1900 | 2.90% | 0.9218 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 8 | 2 | 16 | avx512_c08_t16 | AVX512 | 0.009846 | 54.08 | 0.1900 | 2.56% | 0.8148 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 9 | 1 | 9 | avx512_c09_t09 | AVX512 | 0.008905 | 59.80 | 0.1900 | 2.83% | 0.9010 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 9 | 2 | 18 | avx512_c09_t18 | AVX512 | 0.011754 | 45.30 | 0.1900 | 2.15% | 0.6826 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 10 | 1 | 10 | avx512_c10_t10 | AVX512 | 0.009001 | 59.16 | 0.1900 | 2.80% | 0.8913 | 1/1 | 0/0 | incomplete |
| throughput | n8192_b1 | 8192 | 1 | 10 | 2 | 20 | avx512_c10_t20 | AVX512 | 0.009456 | 56.31 | 0.1900 | 2.67% | 0.8485 | 1/1 | 0/0 | incomplete |

## Plotting Data

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_core_wise/control_n1024_2048_8192_nostream/latest_run_avg.csv`
