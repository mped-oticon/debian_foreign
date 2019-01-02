#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script installs foreign-arch Debian userland(s). Runs inside docker


### Tunables

# Debian release running in the emulated architecture
VDEBIAN="stretch"

# Docker-prefix for the rootfs of the emulated debian
PREFIX="/chroots"


function install_foreign_userland
{
    VARCH="${1:-arm64}"        # Emulated architecture, in debian lingo
    VARCHQ="${2:-aarch64}"     # Emulated architecture, in qemu lingo
    VNAME=${VARCH}-${VDEBIAN}  # Name of the emulated debian
    VROOTFS=${PREFIX}/${VNAME} # RootFS of the emulated debian, seen from Host

    mkdir -p ${VROOTFS}
    cd ${VROOTFS}

    # Mount binfmt_misc if not mounted already
    mount | grep -q binfmt_misc || {
        # Mounting binfmt_misc requires --privileged in Docker
        mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
        ls /proc/sys/fs/binfmt_misc
    }

    # Install stuff
    #   debootstrap: Bootstrapping of new Debian userlands
    #   qemu-user-static: Statically-linked QEMUs, i.e. without further dependencies
    #   schroot: A batter chroot. Bind mounts /proc /dev /dev/pts and /sys automatically
    apt-get update
    apt-get install -y debootstrap qemu-user-static schroot

    # Install a 1st stage Debian userland of a foreign architecture
    (cd / && debootstrap --arch ${VARCH} --foreign --variant=minbase ${VDEBIAN} ${VROOTFS})

    # The Host kernel binfmt may look for interpreter at different location than where we just installed qemu at
    # Copy statically-linked qemu into the expected location inside the foreign userland
    kernel_expected=$(awk '$1~/interpreter/{print $2}' /proc/sys/fs/binfmt_misc/qemu-${VARCHQ})
    cp $(which -a qemu-${VARCHQ}-static) ${VROOTFS}/${kernel_expected}

    # Make schroot happy with slim debian host, Create files if not there already
    test -e /etc/services  || touch /etc/services
    test -e /etc/protocols || touch /etc/protocols
    test -e /etc/networks  || touch /etc/networks

# Do not indent or config file will not be understood by schroot!
echo "[${VNAME}]
description=Debian ${VDEBIAN} (${VARCH})
directory=${VROOTFS}
root-users=$(whoami)
users=$(whoami)
type=directory" | tee /etc/schroot/chroot.d/${VNAME}

    # Add fstab entry to the guest-chroots, if not added already
    grep -q /docker_root /etc/schroot/default/fstab || {
        # Forward whole Host's root file system to be visible by every guest
        echo "/ /docker_root none rw,rbind 0 0"  >> /etc/schroot/default/fstab
    }

    # Enter the emulated and chrooted userland, to finalize the userland setup
    schroot --directory / -c ${VNAME} -- /debootstrap/debootstrap --second-stage
}

# One-time: debootstrap
# install_foreign_userland arm64  aarch64
install_foreign_userland mips   mips
# install_foreign_userland mipsel mipsel
