#!/bin/bash

TARGET_ARM=arm
TARGET_QEMUARM=qemuarm
BUILD_DIR_X86=build-x86
BUILD_DIR_ARM=build-$TARGET_ARM
BUILD_DIR_QEMUARM=build-$TARGET_QEMUARM
CONFIG_DIR=config
CURRENT_DIR=$(pwd)

echo "Current DIR: $CURRENT_DIR"

case $1 in
  --qemu)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM"

        cp $CURRENT_DIR/$CONFIG_DIR/$TARGET_QEMUARM/local.conf $CURRENT_DIR/$BUILD_DIR_QEMUARM/
        cp $CURRENT_DIR/$CONFIG_DIR/$TARGET_QEMUARM/bblayers.conf $CURRENT_DIR/$BUILD_DIR_QEMUARM/

        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM && \
               bitbake core-image-minimal"
    ;;

  --arm)        
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM"

        cp $CURRENT_DIR/$CONFIG_DIR/$TARGET_ARM/local.conf $CURRENT_DIR/$BUILD_DIR_ARM/
        cp $CURRENT_DIR/$CONFIG_DIR/$TARGET_ARM/bblayers.conf $CURRENT_DIR/$BUILD_DIR_ARM/

        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM && \
               bitbake core-image-minimal"
    ;;

  --all)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c ''
    ;;

  --clean)
        docker container run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c ''
    ;;

  *)
        echo "--qemu - build qemuarm image."
        echo "--arm - build arm image."
        echo "--all - build all images."
        echo "--clean - cleans all the build files."
   ;;
esac

        
        
        

#docker container run --rm -v $(pwd):/work crops/poky \
#sh -c 'source /workdir/poky/oe-init-build-env && bitbake core-image-minimal'

#echo "Compile with UID=${LOCAL_USER_ID} GID=${LOCAL_GROUP_ID} HOME=${LOCAL_HOME_PATH}"

#        --network host \
#        -e "LOCAL_USER_ID=${LOCAL_USER_ID}" \
#        -e "LOCAL_USER_NAME=${LOCAL_USER_NAME}" \
#        -e "LOCAL_GROUP_ID=${LOCAL_GROUP_ID}" \
#        -e "LOCAL_HOME_PATH=${LOCAL_HOME_PATH}" \
