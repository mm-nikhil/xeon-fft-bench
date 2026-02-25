VTune Port Profiling Run
========================
Timestamp: 20260225_114546
Case: length=8192, batch=16, ISA=AVX512
Threads tested: 10 20
Analyses requested: hpc-performance hotspots threading

Files:
- run_summary.tsv                : achieved GFLOPS and % of peak model
- vtune_collection_status.tsv    : per-analysis success/unsupported/failure
- t*/benchmark_*t.log            : raw benchmark output
- t*/<analysis>_*t.summary.txt   : VTune summary report
- t*/<analysis>_*t.topdown.txt   : VTune top-down report
- t*/<analysis>_*t.hwevents.txt  : VTune hardware events report
- t*/<analysis>_*t.port_metrics.txt: grep-filtered port/vector-related lines

Notes:
- If status is UNSUPPORTED for hardware-counter analyses, this VTune build
  cannot provide port-level PMU metrics on this CPU. In that case, use an
  older VTune release that supports Skylake-X PMU event mapping, or collect
  equivalent counters with a supported PMU toolchain.
