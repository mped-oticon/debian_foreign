#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script wraps gcc, adapting command line options for Zephyr CMake

function gccwrap
{
    local num_params=$#
    local -a parms=( "$@" )

    for (( i=(($num_params - 1)); i>=0; i-- ))
    do
        local ith_arg="${parms[$i]}"
        # echo "$i : $ith_arg" 1>&2

        case "$ith_arg" in
            -m32)                               unset parms[$i] ;;
            -fno-asynchronous-unwind-tables)    unset parms[$i] ;;
            "-D_FORTIFY_SOURCE=2")              unset parms[$i] ;;
        esac
    done

    if [[ "$PWD" == *"/bsim/"* ]]; then
        prefix_params="-g -ggdb"
    fi

    if [[ "$PWD" == *"/zephyr/"* ]]; then
        prefix_params="-g -ggdb -static" # Statically compile + enable debug to permit GDB symbol resolution
    fi

    set -- "${prefix_params} ${parms[@]}"

    echo "(cd $PWD && /usr/bin/g++.real $@)" 1>&2
    exec /usr/bin/g++.real $@
}

gccwrap $@
