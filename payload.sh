#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script runs payload commands for each architecture

function for_each_arch
{
    arches=(arm64 mips mipsel)
    for arch in ${arches[@]} ; do
        schroot --directory / -c ${arch}-stretch -- $@
    done
}

# Payload
for_each_arch uname -a
for_each_arch apt-get update
for_each_arch apt-get install -y file
for_each_arch file /bin/true
