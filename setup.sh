# Project: A Deterministic User-Space NVMe Driver
# Author: Guillaume Wantiez 
# License: Creative Commons Attribution 4.0 International (CC BY 4.0)
# 
# You are free to use, modify, and distribute this software as long as 
# the original author is credited.

#!/bin/bash

# Configuration
ARCH="riscv64"
CROSS="riscv64-linux-gnu-"
BB_VER="1.36.1"
TP_DIR="$(pwd)/thirdparties/non-permanent"
ROOTFS="$TP_DIR/rootfs"
TOOLCHAIN_WEBPATH="https://toolchains.bootlin.com/downloads/releases/toolchains/riscv64-lp64d/tarballs/riscv64-lp64d--musl--stable-2025.08-1.tar.xz"
TOOLCHAIN_NAME="riscv64-lp64d--musl--stable-2025.08-1"

echo "--- 1. Reseting thirdparties ---"
sudo umount -l $ROOTFS/dev $ROOTFS/proc $ROOTFS/sys 2>/dev/null || true

if [ ! -d "./thirdparties" ]; then
	mkdir thirdparties
	mkdir thirdparties/permanent
	mkdir thirdparties/non-permanent
else
	echo "thirdparties directory existing, skipping (make sure thirdparties/permanent and thirdparties/non-permanent exists too !)"
fi

echo "--- 2. Building BusyBox in $TP_DIR ---"
cd $TP_DIR
rm -rdf rootfs/

if [ ! -d "busybox-$BB_VER" ]; then
    wget -qO- https://busybox.net/downloads/busybox-$BB_VER.tar.bz2 | tar -xjf -
fi

cd busybox-$BB_VER
make ARCH=riscv CROSS_COMPILE=$CROSS defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_PIE=y/# CONFIG_PIE is not set/' .config
sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/' .config

make ARCH=riscv CROSS_COMPILE=$CROSS -j$(nproc)
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j$(nproc) install CONFIG_PREFIX=$ROOTFS
cd ../..

echo "--- 3. Creating Initrd with Folder Sharing ---"
mkdir -p $ROOTFS/dev $ROOTFS/proc $ROOTFS/sys $ROOTFS/etc $ROOTFS/src $ROOTFS/lib

# Revised /init script
cat <<EOF > $ROOTFS/init
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# --- Mount only your source/projects directory ---
# 'projectshare' is the tag we will use in the QEMU command
mount -t virtiofs projectshare /src

echo "------------------------------------------------"
echo "NVMe Research Environment Loaded"
echo "Shared projects are available in /src"
echo "------------------------------------------------"

cd src/
./nvme_setup.sh

exec /bin/sh
EOF

chmod +x $ROOTFS/init

# Cpio packing, pack the Busybox
echo "--- 4. Packing rootfs  ---"
cd $ROOTFS
find . -mindepth 1 | cpio -H newc -o | gzip -9 > $TP_DIR/../rootfs.cpio.gz
cd ../../../

echo "--- 5. Compile kernel on RISC-V target ---"

LINUX_PATH="thirdparties/permanent/linux"
IMAGE_PATH="thirdparties/Image"
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Kernel Image not found. Building..."
    if [ ! -d "$LINUX_PATH" ]; then 
        mkdir -p thirdparties/permanent
        cd thirdparties/permanent
        git clone --depth=1 https://github.com/torvalds/linux.git
        cd ../../
    fi
    cd thirdparties/permanent/linux
    pwd 
    cp ../../../riscv_config_linux .config
    make ARCH=riscv CROSS_COMPILE=$CROSS oldconfig
    make ARCH=riscv CROSS_COMPILE=$CROSS -j$(nproc)
    riscv64-linux-gnu-objcopy -O binary vmlinux Image
    mv Image ../../
    cd ../../../
else
    echo "Kernel Image already exists."
fi

echo "--- 6. Generate NVMe disk ---"
qemu-img create -f raw thirdparties/nvme_disk.img 1G

echo "--- 7.1 Tools -- Toolchain compilation ---"
cd thirdparties/permanent

if [ ! -d $TOOLCHAIN_NAME ]; then
	wget $TOOLCHAIN_WEBPATH
	tar -xvf $TOOLCHAIN_NAME.tar.xz
fi

echo "--- 7.2. Tools -- Creating Qemu Env ---"
if [ ! -d "qemu" ]; then
    echo "QEMU directory not found. Cloning and building qemu-system-riscv64..."
    git clone --depth 1 https://github.com/qemu/qemu.git
    cd qemu
    ./configure --target-list=$ARCH-softmmu
    make -j$(nproc)
    cd ..
else
    echo "QEMU directory exists. Skipping clone."
fi
cd ../../

echo "--- DONE ---"
