#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script installs a GCC wrapper without messing up apt's db

SCRIPTS_DIR=/docker_root/this_dir/inside_docker/inside_chroots

GCC_PATH="$(which gcc)"
GXX_PATH="$(which g++)"


if [ -f "${GCC_PATH}.real" -o -f "${GXX_PATH}.real" ]
then
    echo "Already installed"
else
    echo "Installing..."

    dpkg-divert --add --rename --divert "${GCC_PATH}.real" "${GCC_PATH}"
    cp "${SCRIPTS_DIR}/gcc-wrapper.sh" "${GCC_PATH}-wrapper"
    chmod a+rx "${GCC_PATH}-wrapper"
    ln -s "${GCC_PATH}-wrapper" "${GCC_PATH}"

    dpkg-divert --add --rename --divert "${GXX_PATH}.real" "${GXX_PATH}"
    cp "${SCRIPTS_DIR}/g++-wrapper.sh" "${GXX_PATH}-wrapper"
    chmod a+rx "${GXX_PATH}-wrapper"
    ln -s "${GXX_PATH}-wrapper" "${GXX_PATH}"
fi
