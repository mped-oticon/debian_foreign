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
        case "$ith_arg" in
            -m32)                               unset parms[$i] ;;
            -fno-asynchronous-unwind-tables)    unset parms[$i] ;;
            "-D_FORTIFY_SOURCE=2")              unset parms[$i] ;;
        esac
    done

    # Statically compile + enable debug to permit GDB symbol resolution
    set -- "-g -ggdb -static ${parms[@]}"

    echo "(cd $PWD && /usr/bin/gcc.real $@)"
    exec /usr/bin/gcc.real $@
}

gccwrap $@
