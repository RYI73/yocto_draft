# meta-firebat/recipes-kernel/linux/linux-yocto_%.bbappend

# Add local files directory for kernel (modern syntax)
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://firebat-i915.cfg"

KERNEL_FEATURES += "i915"

KERNEL_CONFIG_FRAGMENTS += "file://firebat-i915.cfg"
