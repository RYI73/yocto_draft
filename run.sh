#!/bin/bash

TARGET_ARM=arm
TARGET_QEMUARM=qemuarm
TARGET_X86=x86
BUILD_DIR_X86=build-$TARGET_X86
BUILD_DIR_ARM=build-$TARGET_ARM
BUILD_DIR_QEMUARM=build-$TARGET_QEMUARM
CONFIG_DIR=config
CURRENT_DIR=$(pwd)

case $1 in
  --qemu)
        qemu-system-arm \
          -M virt -cpu cortex-a15 -m 256 \
          -kernel $BUILD_DIR_QEMUARM/tmp/deploy/images/qemuarm/zImage \
          -drive if=none,file=$BUILD_DIR_QEMUARM/tmp/deploy/images/qemuarm/core-image-minimal-qemuarm.ext4,format=raw,id=hd0 \
          -device virtio-blk-device,drive=hd0 \
          -nographic \
          -serial mon:stdio \
          -append "root=/dev/vda rw console=ttyAMA0 mem=256M ip=dhcp"
    ;;

  --x86)
        qemu-system-arm \
          -M virt -cpu cortex-a15 -m 256 \
          -kernel $BUILD_DIR_X86/tmp/deploy/images/qemuarm/zImage \
          -drive if=none,file=$BUILD_DIR_X86/tmp/deploy/images/$TARGET_X86/core-image-minimal-$TARGET_X86.ext4,format=raw,id=hd0 \
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
        --workdir=/workdir \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_X86 && /bin/bash" 
    ;;

  *)
        echo "--qemu - run qemuarm image on QEMU."
        echo "--arm - run arm image."
        echo "--x86 - run x86 image."
        echo "--docker - run docker container crops/poky."
   ;;
esac
