#!/bin/bash
# Author: Mark Ruvald Pedersen (MPED)
# Description: This script builds a docker image and optionally uploads it to Docker Hub
# Please do not depend on my Docker Hub image, rather fork it yourself.
# You want to have $DOCKER_ID_USER set correctly if you want to push to your own Docker Hub repo!

IMAGE_V0=debian:stretch-slim              # Input: Some small Debian [AMD64] (or other distro which has debootstrap)
IMAGE_V1=debian_foreign_base              # Output: Debian [AMD64] containing other Debians of differing architectures via schroot
IMAGE_V2=debian_foreign                   # Output: Same as IMAGE_V1 with chroots being populated with packages
IMAGE_V3=debian_foreign_fetched           # Output: Same as IMAGE_V2 with zephyr having been fetched
IMAGE_V4=debian_foreign_built             # Output: Same as IMAGE_V3 with zephyr having been built

DOCKER_RUN_OPTS="--privileged -v ${PWD}:/this_dir -it"


function docker_commit
{
    local image_from="$1"
    local image_to="$2"

    # Get ID of the previous exited instance of $image_from
    container_id=$(sudo docker container ls --all --quiet --latest --filter ancestor=${image_from} --filter status=exited)

    # Commit that container instance to a new image, call it $image_to
    sudo docker commit -m"Debian with another foreign debians inside it" ${container_id} ${image_to}
}


### Run: Install base image for each architecture and setup chroots
if [[ "$@" == *"--setup_foreigns"* ]]; then
    # Run the base image, with this directory bind-mounted inside, then run script.
    # The script setup_foreigns.sh will install the foreign userlands etc
    sudo docker run                        \
        ${DOCKER_RUN_OPTS}                 \
        ${IMAGE_V0}                        \
        bash -x /this_dir/inside_docker/setup_foreigns.sh

    docker_commit ${IMAGE_V0} ${IMAGE_V1}
fi


### Run: Under every architecture's chroot, install some packages
if [[ "$@" == *"--setup_chroots"* ]]; then
    sudo docker run                        \
        ${DOCKER_RUN_OPTS}                 \
        ${IMAGE_V1}                        \
        bash -x /this_dir/inside_docker/for_each_arch.sh bash -x /docker_root/this_dir/inside_docker/inside_chroots/setup_chroot.sh

    # TODO: Test if setup_chroot executed correctly

    docker_commit ${IMAGE_V1} ${IMAGE_V2}
fi


### Push the clean image
if [[ "$@" == *"--push"* ]]; then
    # Then push
    sudo docker tag ${IMAGE_V2} ${DOCKER_ID_USER:-mpedoticon}/${IMAGE_V2}
    sudo docker push ${DOCKER_ID_USER:-mpedoticon}/${IMAGE_V2}
fi


### Run: Under every architecture's chroot, fetch zephyr
if [[ "$@" == *"--fetch_all"* ]]; then
    sudo docker run                        \
        ${DOCKER_RUN_OPTS}                 \
        ${IMAGE_V2}                        \
        bash -x /this_dir/inside_docker/for_each_arch.sh bash -x /docker_root/this_dir/inside_docker/inside_chroots/zephyr.sh fetch_all

    # TODO: Test if payload executed correctly

    docker_commit ${IMAGE_V2} ${IMAGE_V3}
fi

### Run: Under every architecture's chroot, build zephyr
if [[ "$@" == *"--build_all"* ]]; then
    sudo docker run                        \
        ${DOCKER_RUN_OPTS}                 \
        ${IMAGE_V3}                        \
        bash -x /this_dir/inside_docker/for_each_arch.sh bash -x /docker_root/this_dir/inside_docker/inside_chroots/zephyr.sh build_all

    # TODO: Test if payload executed correctly

    docker_commit ${IMAGE_V3} ${IMAGE_V4}
fi


### Run: Let user play around in the last image
if [[ "$@" == *"--interactive"* ]]; then
    sudo docker run                        \
        ${DOCKER_RUN_OPTS}                 \
        ${IMAGE_V4}                        \
        bash
fi
