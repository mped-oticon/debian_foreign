#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script runs a previously foreign-compiled zephyr under gdb

function run_under_gdb
{
    local ZEPHYR_ELF=/root/zephyr/samples/hello_world/build/zephyr/zephyr.elf
    local VROOTFS=/chroots/mips-stretch
    local GDB_PORT=6789

    cd /chroots/mips-stretch && (
        schroot --directory / -c ${arch}-stretch -- qemu-${arch}-static -g ${GDB_PORT} "${ZEPHYR_ELF}" &

        gdb-multiarch \
        -q \
        -ex "layout split" \
        -ex "focus cmd" \
        -ex "set arch ${arch}" \
        -ex "set endian big" \
        -ex "target remote localhost:${GDB_PORT}" \
        "${VROOTFS}/${ZEPHYR_ELF}"
    )
}

run_under_gdb
