#!/bin/bash

TARGET_ARM=arm
TARGET_QEMUARM=qemuarm
BUILD_DIR_X86=build-x86
BUILD_DIR_ARM=build-$TARGET_ARM
BUILD_DIR_QEMUARM=build-$TARGET_QEMUARM
CONFIG_DIR=config
ROOT_DIR=$(pwd)

case $1 in
  --qemu)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM"

        cp $ROOT_DIR/$CONFIG_DIR/$TARGET_QEMUARM/local.conf $ROOT_DIR/$BUILD_DIR_QEMUARM/conf/
        cp $ROOT_DIR/$CONFIG_DIR/$TARGET_QEMUARM/bblayers.conf $ROOT_DIR/$BUILD_DIR_QEMUARM/conf/

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

        cp $ROOT_DIR/$CONFIG_DIR/$TARGET_ARM/local.conf $ROOT_DIR/$BUILD_DIR_ARM/conf/
        cp $ROOT_DIR/$CONFIG_DIR/$TARGET_ARM/bblayers.conf $ROOT_DIR/$BUILD_DIR_ARM/conf/

        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM && \
               bitbake core-image-minimal
        "
    ;;

  --all)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c ''
    ;;

  --create)        
        if [ -z "$2" ]; then
            echo "ERROR!!! Specify the name of package: $0 --create new-package."
            exit 1 # terminate if an error occurs
        fi

        PACKAGE_NAME=$2
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env && \
               bitbake-layers create-layer /workdir/meta-$PACKAGE_NAME
               bitbake-layers add-layer /workdir/meta-$PACKAGE_NAME
        "
    ;;

  --build-arm)        
        if [ -z "$2" ]; then
            echo "ERROR!!! Specify the name of package: $0 --build new-package."
            exit 1 # terminate if an error occurs
        fi

        PACKAGE_NAME=$2
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM && \
               bitbake $PACKAGE_NAME
        "
    ;;

  --build-qemu)        
        if [ -z "$2" ]; then
            echo "ERROR!!! Specify the name of package: $0 --build new-package."
            exit 1 # terminate if an error occurs
        fi

        PACKAGE_NAME=$2
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM && \
               bitbake $PACKAGE_NAME
        "
    ;;

  --clean-qemu)
        if [ -z "$2" ]; then
            echo "Clean all builds."
        else
            PACKAGE_NAME=$2
            docker run \
            -v $(pwd):/workdir \
            crops/poky \
            sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM && \
                   bitbake $PACKAGE_NAME -c clean
            "
        fi

    ;;

  --clean-arm)
        if [ -z "$2" ]; then
            echo "Clean all builds."
        else
            PACKAGE_NAME=$2
            docker run \
            -v $(pwd):/workdir \
            crops/poky \
            sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM && \
                   bitbake $PACKAGE_NAME -c clean
            "
        fi

    ;;

  --sdk-qemu)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM && \
               bitbake core-image-minimal -c populate_sdk_ext
        "

    ;;

  --sdk-arm)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM && \
               bitbake core-image-minimal -c populate_sdk_ext
        "

    ;;

  *)
        echo "--qemu - build qemuarm image."
        echo "--arm - build arm image."
        echo "--all - build all images."
        echo "--create - creates new package with specified name."
        echo "--build-arm - builds new package for arm with specified name."
        echo "--build-qemu - builds new package for qemuarm with specified name."
        echo "--sdk-arm - builds eSDK for arm."
        echo "--sdk-qemu - builds eSDK for qemuarm."
        echo "--clean-qemu - cleans qemuarm build files."
        echo "--clean-arm - cleans arm build files."
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
