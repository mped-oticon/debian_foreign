#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script contains the payload commands

WORKSPACE="${HOME}"


function fetch_zephyr
{
    mkdir -p "$WORKSPACE" && cd "$WORKSPACE" && (

        # We do not need to Zephyr SDK for native_posix, as we rely on the Host's GCC
        # Fetch Zephyr SDK: https://docs.zephyrproject.org/latest/getting_started/installation_linux.html#zephyr-sdk
        # {
        #     wget https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/0.9.5/zephyr-sdk-0.9.5-setup.run
        #     sh zephyr-sdk-0.9.5-setup.run --quiet --nox11 -- -d /opt/zephyr-sdk
        # }

        # Fetch Zephyr
        {
            # Some hacks are required; can't use upstream master yet
            git clone -b master-nativeposix_mips https://github.com/mped-oticon/zephyr

            pip3 install --user -r zephyr/scripts/requirements.txt
        }
    )
}

function build_zephyr
{
    mkdir -p "$WORKSPACE" && cd "$WORKSPACE" && (

        cd zephyr && (
            export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
            unset ZEPHYR_SDK_INSTALL_DIR

            source zephyr-env.sh

            cd samples/hello_world && (
                rm -rf ~/.cache/zephyr
                rm -rf build; mkdir -p build && cd build && (
                    cmake -GNinja -DBOARD=native_posix .. && ninja
                )
            )
        )

    )
}

function fetch_bsim
{
    mkdir -p "$WORKSPACE" && cd "$WORKSPACE" && (

        git config --global user.email "you@example.com"
        git config --global user.name "Your Name"
        git config --global color.ui false

        # ssh-keyscan github.com >> ~/.ssh/known_hosts

        mkdir -p bsim && cd bsim && (
            repo init -u https://github.com/BabbleSim/manifest.git -m everything.xml -b master
            sed -i 's#ssh://git@github.com/BabbleSim#https://github.com/BabbleSim#g' $(grep -ERl "ssh://git@github.com/BabbleSim" .* 2>/dev/null)
            repo sync
        )
    )
}

function build_bsim
{
    mkdir -p "$WORKSPACE" && cd "$WORKSPACE" && (

        cd bsim && (
            sed -i 's/setarch i386 //g'  components/ext_libCryptov1/Makefile.library
            sed -i 's# &> /dev/null# #g' components/ext_libCryptov1/Makefile.library
            make everything -j $(nproc)
        )
    )
}

function fetch_all {
    fetch_zephyr
    fetch_bsim
}

function build_all {
    build_zephyr
    build_bsim
}

# User must pass the name of one of the functions above
$1
