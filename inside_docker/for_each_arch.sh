#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script runs payload commands for each architecture

function for_each_arch
{
    #arches=(arm64 mips mipsel)
    arches=(mips)
    for arch in ${arches[@]} ; do
        schroot --directory / -c ${arch}-stretch -- $@
    done
}

for_each_arch $@
