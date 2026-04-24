# A Deterministic User-Space NVMe Driver with Deadline-Aware I/O Scheduling for High-Performance Storage

This project focuses on developing a high-performance, user-space NVMe driver for the **RISC-V** architecture.
By bypassing the Linux kernel jitter through polling-based I/O and implementing an deadline aware scheduler
this research aims to significantly reduce **P99 tail latency** in storage operations.

## Architecture Overview
* **Target Architecture**: RISC-V 64.
* **Isolation**: Utilizes a QEMU/VFIO environment with **IOMMU isolation** for secure, direct hardware access.
* **Operating System**: Custom minimal Linux environment built with a cross-compiled kernel and BusyBox.

## Prerequisites
To build and run this environment, ensure the following tools are installed on your host system:
* **Toolchain**: `riscv64-linux-gnu-` cross-compiler.
* **Utilities**: `make`, `gcc`, `wget`, `cpio`, `qemu-img`, and `gzip`.
* **Kernel Sources**: The setup script automatically clones the Linux kernel if not present.

## Run

To initialize the research environment, compile the dependencies, and generate the necessary filesystem images, execute the setup script:

```bash
chmod +x setup.sh
./setup.sh
```

## Important consideration and license

### Research Status
This is a **research project**. It is designed for academic evaluation of I/O scheduling and deterministic execution on RISC-V architectures. As such:
* It is **not suitable** for production environments or real-world applications.
* The code may lack the robustness, error handling, and security hardening required for commercial use.
* Users should exercise caution when deploying this driver with actual hardware.
* This repository is research in progress and need some improvement particulary in the benchmark and the testing environement, feel free to add features if intrested and make a pull request.

### License
This work is licensed under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license.

You are free to:
* **Share**: Copy and redistribute the material in any medium or format.
* **Adapt**: Remix, transform, and build upon the material for any purpose, even commercially.

Under the following terms:
* **Attribution**: You must give appropriate credit to the original author (**Guillaume Wantiez** or **XMR-D** and corresponding github link), provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
