#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script runs some tests from in an external workspace

(
    cd /docker_root/this_dir/inside_docker/inside_chroots/workspace/ && {
        find . -type f | grep CMakeCache.txt | xargs rm
        rm -rf git/build/

        # (cd git/tools/bsim/ && make clean)

        export CC=/usr/bin/gcc
        git/fw/rf/scripts/bash_tests.sh run_tests run_a_test tc_build_bsim
        git/fw/rf/scripts/bash_tests.sh run_tests run_a_test tc_ble_nrf52peripheral_nrf52central
    }
)
