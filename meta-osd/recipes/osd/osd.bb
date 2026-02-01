SUMMARY = "X11 OSD utility"
LICENSE = "MIT"

inherit systemd

SRC_URI = "file://osd.service"

SYSTEMD_SERVICE:${PN} = "osd.service"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/osd.service \
        ${D}${systemd_system_unitdir}/osd.service
}

FILES:${PN} += "${systemd_system_unitdir}"
