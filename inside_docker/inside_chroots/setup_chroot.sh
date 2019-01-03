#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script installs packages into a chroot.

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

apt-get -t testing install -y make cmake ninja-build
apt-get -t testing install -y gcc g++ build-essential
apt-get -t testing install -y gperf gdb
apt-get -t testing install -y device-tree-compiler
apt-get install -y --no-install-recommends git dfu-util less strace vim wget python3-pip python3-setuptools python3-wheel xz-utils file

bash -x /docker_root/this_dir/inside_docker/inside_chroots/install_gcc_wrapper.sh
