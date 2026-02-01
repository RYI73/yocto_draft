#!/bin/bash

ROOT_DIR=$(pwd)
CONFIG_DIR=config

# Actions list
ACTIONS=(
    create
    clean
)

# Targets list
declare -A TARGETS=(
    [rp4]=raspberrypi4
    [qemu-arm]=qemuarm
    [x86]=genericx86-64
)

# Actions list
BUILDS=(
    image
    package
    sdk
)

# BUILD_DIR_X86=build-$TARGET_X86
# BUILD_DIR_ARM=build-$TARGET_ARM
# BUILD_DIR_QEMUARM=build-$TARGET_QEMUARM

usage() {
    echo "Usage: $0 [--build|-b BLDNAME] [--target|-t TRGNAME] [--action|-a ACTNAME] [--package|-p PKGNAME]"
    echo "  --action,  -a ACTNAME  Set the action name: ${ACTIONS[@]}"
    echo "  --build,   -b BLDNAME  Set the purpose of the build: ${BUILDS[@]}"
    echo "  --target,  -t TRGNAME  Set the target name: ${!TARGETS[*]}"
    echo "  --package, -p PKGNAME  Set the package name."
    echo "  --help, -h             Print help"
    exit 1
}
# ----
ACTION=""
BUILD=""
TARGET=""
PACKAGE=""

# OPTIONS=$(getopt -o p:d: --long proj-name,proj-dir,help -- "$@")
OPTIONS=$(getopt -o a:b:t:p: --long action,build,target,package,help -- "$@")
if [ $? -ne 0 ]; then
    usage
fi

eval set -- "$OPTIONS"

# Parse args
while true; do
    case "$1" in
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -b|--build)
            BUILD="$2"
            shift 2
            ;;
        -p|--package)
            PACKAGE="$2"
            shift 2
            ;;
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
done

BUILD_DIR=build-$TARGET

# if [ -z "$proj_name" ]; then
#     echo "Error: Missing '--proj-name' argument."
#     usage
# fi
# if [ -z "$proj_dir" ]; then
#     echo "Error: Missing '--proj-dir' argument."
#     usage
# fi


# if [[ -z "$BUILD" || -z "$TARGET" ]]; then

# if [[ -z "$ACTION" || -z "${ACTIONS[$ACTION]}" ]]; then
#     echo "ERROR!!! Specify the action"
#     echo "Available actions: ${!ACTIONS[*]}"
#     exit 1
# fi


echo ACTION=$ACTION
echo BUILD=$BUILD
echo TARGET=$TARGET
echo PACKAGE=$PACKAGE
echo BUILD_DIR=$BUILD_DIR


# if [[ -z "$ACTION" ]]; then
#     echo "Action: $ACTION"
# else
#     if [[ -z "$IMAGE_NAME" ]]; then
#         echo "ERROR!!! Specify the target: $0 --image <your target>."
#     else
#         if [[ -z "${TARGETS[$IMAGE_NAME]}" ]]; then
#             echo "ERROR!!! Unknown target <$IMAGE_NAME>"
#         fi
#     fi
#     echo "Available targets: ${!TARGETS[*]}"
#     exit 1 # terminate if an error occurs
# fi



exit 0

case $BUILD in
  --image)
        case $IMAGE_NAME in
          --qemu-arm)
                docker run \
                -v $(pwd):/workdir \
                crops/poky \
                sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM"

                cp $ROOT_DIR/$CONFIG_DIR/$TARGET_QEMUARM/local.conf $ROOT_DIR/$BUILD_DIR_QEMUARM/conf/
                cp $ROOT_DIR/$CONFIG_DIR/bblayers.conf $ROOT_DIR/$BUILD_DIR_QEMUARM/conf/

                docker run \
                -v $(pwd):/workdir \
                crops/poky \
                sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_QEMUARM && \
                       bitbake core-image-minimal"
            ;;

          --rp4)
                docker run \
                -v $(pwd):/workdir \
                crops/poky \
                sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM"

                cp $ROOT_DIR/$CONFIG_DIR/$TARGET_ARM/local.conf $ROOT_DIR/$BUILD_DIR_ARM/conf/
                cp $ROOT_DIR/$CONFIG_DIR/bblayers.conf $ROOT_DIR/$BUILD_DIR_ARM/conf/

                docker run \
                -v $(pwd):/workdir \
                crops/poky \
                sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_ARM && \
                       bitbake core-image-minimal
                "
            ;;

          --x86)
                docker run \
                -v $(pwd):/workdir \
                crops/poky \
                sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_X86"

                cp $ROOT_DIR/$CONFIG_DIR/$TARGET_X86/local.conf $ROOT_DIR/$BUILD_DIR_X86/conf/
                cp $ROOT_DIR/$CONFIG_DIR/bblayers.conf $ROOT_DIR/$BUILD_DIR_X86/conf/

                docker run \
                -v $(pwd):/workdir \
                crops/poky \
                sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_X86 && \
                       bitbake core-image-minimal
                "
            ;;

          *)
                if [[ -z "$IMAGE_NAME" ]]; then
                    echo "ERROR!!! Specify the target: $0 --image <your target>."
                else
                    if [[ -z "${TARGETS[$IMAGE_NAME]}" ]]; then
                        echo "ERROR!!! Unknown target <$IMAGE_NAME>"
                    fi
                fi
                echo "Available targets: ${!TARGETS[*]}"
                exit 1 # terminate if an error occurs
            ;;
        esac

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

  --all)
        docker run \
        -v $(pwd):/workdir \
        crops/poky \
        sh -c ''
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

  --clean-x86)
        if [ -z "$2" ]; then
            echo "Clean all builds."
        else
            PACKAGE_NAME=$2
            docker run \
            -v $(pwd):/workdir \
            crops/poky \
            sh -c "source /workdir/poky/oe-init-build-env /workdir/$BUILD_DIR_X86 && \
                   bitbake virtual/kernel -c cleansstate
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
        echo "--image - build specified image."

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
