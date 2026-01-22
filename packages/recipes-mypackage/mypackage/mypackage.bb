SUMMARY = "Hello world application"
DESCRIPTION = "Custom Yocto application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://main.c \
           file://CMakeLists.txt"

S = "${WORKDIR}"

inherit cmake

do_install() {
    install -d ${D}${bindir}
    install -m 0755 mypackage ${D}${bindir}/mypackage
}
