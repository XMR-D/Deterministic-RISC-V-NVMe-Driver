# Project: A Deterministic User-Space NVMe Driver
# Author: Guillaume Wantiez 
# License: Creative Commons Attribution 4.0 International (CC BY 4.0)
# 
# You are free to use, modify, and distribute this software as long as 
# the original author is credited.

# Path Configuration
QEMU_BIN       = ../thirdparties/permanent/qemu/build/qemu-system-riscv64
VMLINUX        = ../thirdparties/Image
INITRD         = ../thirdparties/rootfs.cpio.gz
NVME_DISK      = ../thirdparties/nvme_disk.img

# Machine & CPU Configuration
# 'aia=aplic-imsic' is the modern RISC-V interrupt standard
QEMU_MACHINE   = virt,aia=aplic-imsic
QEMU_CPU       = max
MEM            = 4G
SMP            = 4

# ON HOST COMPILATION FLAGS
CC = ../thirdparties/permanent/riscv64-lp64d--musl--stable-2025.08-1/bin/riscv64-buildroot-linux-musl-gcc
AR=$(CROSS-COMPILE)ar
INCLUDE=-Iinclude -Iinclude/scheduler -Iinclude/nvme_core_funcs -Ikernel_headers/include 
CFLAGS = -Wall -Wextra -Werror -static -march=rv64gc -march=rv64gc_zihintpause -mabi=lp64d -Ofast -g 
