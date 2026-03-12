# Hardware Details: Intel Xeon W-2155 Workstation Server

This document contains verified hardware specifications for the machine used in all FFT benchmarks in this project.
Source confidence is indicated per field. All system-level data is read directly from the running OS.

---

## CPU: Intel Xeon W-2155

### Identification
| Field | Value | Source |
|---|---|---|
| Processor Number | W-2155 | Intel ARK / `/proc/cpuinfo` |
| Full Name | Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz | `/proc/cpuinfo` |
| Product Collection | Intel Xeon W Processor | Intel ARK |
| Code Name | Products formerly Skylake | Intel ARK |
| Microarchitecture | Skylake-W (Skylake-X variant for workstations) | Intel ARK |
| CPU Family | 6 | `/proc/cpuinfo` |
| CPU Model | 85 (0x55) | `/proc/cpuinfo` |
| Stepping | 4 | `/proc/cpuinfo` |
| Microcode | 0x2007006 (at time of benchmarking) | `/proc/cpuinfo` |
| Launch Date | Q3 2017 (August 29, 2017) | Intel ARK |
| Marketing Status | Discontinued (EOL: December 31, 2023) | Intel ARK |
| Recommended Customer Price | $1,440.00 USD | Intel ARK |

### Process & Physical Die
| Field | Value | Source |
|---|---|---|
| Lithography | 14 nm | Intel ARK (official) |
| Die Size | 484 mm² | technical.city (**third-party**, Intel does not publish this) |
| Transistor Count | Not published | Intel does not disclose; no verified third-party figure found |
| Socket | FCLGA2066 | Intel ARK |
| Package Size | 45 mm × 52.5 mm | Intel ARK |

> **Note on die size:** Intel does not publish die size for this product. The 484 mm² figure is from technical.city (https://technical.city/en/cpu/Xeon-W-2155). WikiChip was inaccessible for cross-verification. This figure is plausible — the Skylake-W die spans the full W-21xx product line (4 to 18 cores) as a single monolithic die with cores disabled for lower-count SKUs.

### Core Topology
| Field | Value | Source |
|---|---|---|
| Physical Cores | 10 | Intel ARK / `lscpu` |
| Logical Threads | 20 (Hyper-Threading ON) | Intel ARK / `lscpu` |
| Sockets | 1 | `lscpu` |
| NUMA Nodes | 1 | `lscpu` |
| Hyper-Threading | Yes | Intel ARK |
| Max CPU Configuration | 1S Only (single socket) | Intel ARK |

### Clocks & Power
| Field | Value | Source |
|---|---|---|
| Base Frequency | 3.30 GHz | Intel ARK / `lscpu` |
| Max Single-Core Turbo | 4.50 GHz | Intel ARK / `lscpu` (cpuinfo_max_freq) |
| Min Frequency | 1.20 GHz | `lscpu` (cpufreq min) |
| Intel Turbo Boost | 2.0 | Intel ARK |
| Intel Turbo Boost Max 3.0 | No | Intel ARK |
| TDP | 140 W | Intel ARK |
| T_case (max case temp) | 68°C | Intel ARK |

### Cache Hierarchy
| Level | Type | Size | Source |
|---|---|---|---|
| L1 Data | Per-core | 32 KB | `/sys/devices/system/cpu/cpu0/cache/index0/size` |
| L1 Instruction | Per-core | 32 KB | `/sys/devices/system/cpu/cpu0/cache/index1/size` |
| L2 | Unified, per-core | 1024 KB (1 MB) | `/sys/devices/system/cpu/cpu0/cache/index2/size` |
| L3 | Unified, shared | 13.75 MB (14080 KB) | `/proc/cpuinfo` + `/sys` |

Total L1: 640 KB (10 × 64 KB) | Total L2: 10 MB (10 × 1 MB) | L3: 13.75 MB shared.

### Instruction Set Extensions
All flags confirmed directly from `/proc/cpuinfo`:

| Extension | Supported |
|---|---|
| SSE / SSE2 / SSE3 / SSSE3 / SSE4.1 / SSE4.2 | Yes |
| AVX / AVX2 | Yes |
| AVX-512F (Foundation) | Yes |
| AVX-512DQ (Doubleword & Quadword) | Yes |
| AVX-512BW (Byte & Word) | Yes |
| AVX-512CD (Conflict Detection) | Yes |
| AVX-512VL (Vector Length Extensions) | Yes |
| FMA (Fused Multiply-Add) | Yes |
| AES-NI | Yes |
| # of AVX-512 FMA Units per core | **2** (Port 0 and Port 5) | Intel ARK (official) |

The 2 independent 512-bit FMA units per core are critical for peak FLOP throughput (confirmed by Intel ARK field "# of AVX-512 FMA Units: 2").

### Peak Theoretical Throughput (Single Precision, AVX-512)
```
Peak SP GFLOPS = Cores × FMA_units × SIMD_width × FLOP_per_FMA × Frequency
              = 10 × 2 × 16 × 2 × 3.3 GHz = 2,112 SP GFLOPS  (base clock)
              = 10 × 2 × 16 × 2 × 4.5 GHz = 2,880 SP GFLOPS  (max turbo ceiling)
```
> These are the theoretical upper bounds. In practice, FFT workloads achieve ~20–25% of compute peak due to memory bandwidth bottlenecks (see benchmark results).

---

## Memory

### Installed Configuration (read from OS)
| Field | Value | Source |
|---|---|---|
| Total Installed | 64 GB (4 × 16 GB DIMMs) | `/sys/devices/system/edac/mc/*/dimm*/size` |
| OS-visible RAM | ~62.3 GiB (≈65,351 MB) | `/proc/meminfo` |
| DIMM Type | Unbuffered DDR4 (UDIMM) | `/sys/devices/system/edac/mc/*/dimm*/dimm_mem_type` |
| Memory Controllers | 2 (IMC#0, IMC#1 — "Skylake Socket#0 IMC#0/1") | `/sys/devices/system/edac/mc/*/mc_name` |
| DIMMs populated | 4 slots (2 per IMC: dimm0 + dimm2) | `/sys/devices/system/edac/mc/` |
| ECC | Supported by CPU; UDIMM used (ECC status of DIMMs unknown without dmidecode) | Intel ARK + EDAC type |
| Configured Speed | Unknown — no dmidecode/sudo access; max supported is 2666 MT/s | — |

> **Note:** `dmidecode` requires root to report DIMM speed. The exact configured DDR4 speed (2133 / 2400 / 2666 MT/s) could not be read from the OS at the time of writing.

### CPU Memory Specification (from Intel ARK)
| Field | Value | Source |
|---|---|---|
| Max Supported Memory | 512 GB | Intel ARK |
| Memory Types Supported | DDR4 1600 / 1866 / 2133 / 2400 / 2666 MT/s | Intel ARK |
| Number of Memory Channels | 4 | Intel ARK |
| Max Memory Bandwidth | **85.3 GB/s** | Intel ARK |
| ECC Memory Supported | Yes | Intel ARK |
| Physical Address Extensions | 46-bit | Intel ARK |

> **Bandwidth note:** 85.3 GB/s is the theoretical maximum at DDR4-2666 with all 4 channels populated. Our installed 4-DIMM config (2 per IMC × 2 IMCs) corresponds to a 4-channel configuration. Effective bandwidth will be lower due to access patterns and DRAM overhead.

---

## I/O & Connectivity

| Field | Value | Source |
|---|---|---|
| PCIe Version | 3.0 | Intel ARK |
| Max PCIe Lanes | 48 | Intel ARK |
| PCIe Configurations | ×4, ×8, ×16 | Intel ARK |
| Bus Speed (DMI3) | 8 GT/s | Intel ARK |
| UPI Links | 0 (single-socket only) | Intel ARK |
| Intel VMD (Volume Management Device) | Yes | Intel ARK |

---

## Platform & Chipset

From PCI device enumeration (`lspci`):
- Host bridge: `Intel Corporation Sky Lake-E DMI3 Registers (rev 04)` — confirms Skylake-X/W platform
- Memory controller product (lshw): `200 Series/Z370 Chipset Family Power Management Controller` — this is the PCH (Platform Controller Hub); the workstation counterpart is C422 chipset
- CBDMA (Crystal Beach DMA) engines present: 4 channels (IOAT DMA)

---

## Operating System & Kernel

| Field | Value | Source |
|---|---|---|
| OS | Red Hat Enterprise Linux (RHEL) 8.x | `/etc/os-release` (inferred from kernel version) |
| Kernel | 4.18.0-553.30.1.el8_10.x86_64 | `uname -r` |
| Architecture | x86_64 | `uname -m` |

---

## Summary Table

| Property | Value |
|---|---|
| CPU Model | Intel Xeon W-2155 |
| Microarchitecture | Skylake-W (14 nm) |
| Die Size | 484 mm² (third-party; unconfirmed by Intel) |
| Cores / Threads | 10 / 20 |
| Base / Max Turbo Clock | 3.30 GHz / 4.50 GHz |
| TDP | 140 W |
| AVX-512 FMA Units/core | 2 |
| Peak SP GFLOPS (base) | 2,112 GFLOPS |
| L1 / L2 / L3 Cache | 32+32 KB / 1 MB / 13.75 MB |
| Installed RAM | 64 GB DDR4 UDIMM (4 × 16 GB) |
| Memory Channels | 4 |
| Max Memory Bandwidth | 85.3 GB/s (theoretical, DDR4-2666) |
| PCIe | 3.0, 48 lanes |
| Socket | FCLGA2066 |

---

## References

- **Intel ARK (official):** https://www.intel.com/content/www/us/en/products/sku/125042/intel-xeon-w2155-processor-13-75m-cache-3-30-ghz/specifications.html
- **technical.city (die size):** https://technical.city/en/cpu/Xeon-W-2155
- **System files:** `/proc/cpuinfo`, `lscpu`, `/sys/devices/system/cpu/`, `/sys/devices/system/edac/`
