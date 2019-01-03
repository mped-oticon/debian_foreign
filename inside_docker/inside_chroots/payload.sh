#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script contains the payload commands


function build_zephyr
{
    local ZEPHYR_WORKSPACE="${HOME}"

    cd "$ZEPHYR_WORKSPACE" && (

        # We do not need to Zephyr SDK for native_posix, as we rely on the Host's GCC
        # # Setup SDK: https://docs.zephyrproject.org/latest/getting_started/installation_linux.html#zephyr-sdk
        # {
        #     wget https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/0.9.5/zephyr-sdk-0.9.5-setup.run
        #     sh zephyr-sdk-0.9.5-setup.run --quiet --nox11 -- -d /opt/zephyr-sdk
        # }

        # Setup Zephyr
        {
            # Some hacks are required
            git clone -b master-nativeposix_mips https://github.com/mped-oticon/zephyr

            pip3 install --user -r zephyr/scripts/requirements.txt
        }


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


cmake --version
git --version
gcc --version

build_zephyr
