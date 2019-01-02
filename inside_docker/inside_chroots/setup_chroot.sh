#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script sets up a chroot

# Debug
uname -a
ls --color -l /
ls --color -l /docker_root
ls --color -l /docker_root/this_dir

####

cat << EOF | tee /etc/apt/apt.conf.d/99defaultrelease
APT::Default-Release "stable";
EOF

cat << EOF | tee /etc/apt/sources.list.d/testing.list
deb     http://ftp.debian.org/debian/       testing main contrib non-free
deb-src http://ftp.debian.org/debian/       testing main contrib non-free
deb     http://security.debian.org/         testing/updates  main contrib non-free
EOF

apt-get update

apt-get install -y --no-install-recommends git ninja-build gperf ccache dfu-util device-tree-compiler wget python3-pip python3-setuptools python3-wheel xz-utils file make gcc gcc-multilib cmake build-essential
#pip3 install scikit-build
apt-get -t testing install -y cmake
