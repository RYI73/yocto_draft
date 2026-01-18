#!/bin/bash

TARGET_ARM=arm
TARGET_QEMUARM=qemuarm
BUILD_DIR_X86=build-x86
BUILD_DIR_ARM=build-$TARGET_ARM
BUILD_DIR_QEMUARM=build-$TARGET_QEMUARM
CONFIG_DIR=config
CURRENT_DIR=$(pwd)

case $1 in
  --qemu)
        qemu-system-arm \
          -M virt -cpu cortex-a15 -m 256 \
          -kernel $BUILD_DIR_QEMUARM/tmp/deploy/images/qemuarm/zImage \
          -drive if=none,file=$BUILD_DIR_QEMUARM/tmp/deploy/images/qemuarm/core-image-minimal-qemuarm-20260118122949.rootfs.ext4,format=raw,id=hd0 \
          -device virtio-blk-device,drive=hd0 \
          -nographic \
          -serial mon:stdio \
          -append "root=/dev/vda rw console=ttyAMA0 mem=256M ip=dhcp"
    ;;

  --arm)        
    ;;

  --docker)
        docker run --rm -it \
        -v $(pwd):/workdir \
        crops/poky \
        --workdir=/workdir
    ;;

  *)
        echo "--qemu - run qemuarm image on QEMU."
        echo "--arm - run arm image."
        echo "--docker - run docker container crops/poky."
   ;;
esac
