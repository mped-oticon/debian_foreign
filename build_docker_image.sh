#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script builds and uploads a docker image to Docker Hub
# Please do not depend on my Docker Hub image, rather fork it yourself.
# You want to have $DOCKER_ID_USER set correctly if you want to push to your own Docker Hub repo!

IMAGE_V0=debian:stretch-slim    # Input: Some small Debian [AMD64] (or other distro which has debootstrap)
IMAGE_V1=debian_foreign         # Output: Debian [AMD64] containing other Debians of differing architectures via schroot

# Run the base image, with this directory bind-mounted inside, then run script.
# The script setup_foreign.sh will install the foreign userlands etc
sudo docker run                        \
    --privileged                       \
    -v ${PWD}:/this_dir                \
    -it                                \
    ${IMAGE_V0}                        \
    bash -x /this_dir/setup_foreign.sh

# Get ID of the previous exited instance
container_id=$(sudo docker container ls --all --quiet --latest --filter ancestor=${IMAGE_V0} --filter status=exited)

# Commit that container instance to a new image, call it $IMAGE_V1
sudo docker commit -m"Debian with another foreign debians inside it" ${container_id} ${IMAGE_V1}


### Test and push

# Run some payload
sudo docker run                        \
    --privileged                       \
    -v ${PWD}:/this_dir                \
    -it                                \
    ${IMAGE_V1}                        \
    bash -x /this_dir/payload.sh

# TODO: Test if payload executed correctly. If so, push

# Then push
sudo docker tag ${IMAGE_V1} ${DOCKER_ID_USER:-mpedoticon}/${IMAGE_V1}
sudo docker push ${DOCKER_ID_USER:-mpedoticon}/${IMAGE_V1}
