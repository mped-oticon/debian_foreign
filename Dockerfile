# Author: Mark Ruvald Pedersen (MPED)
# Note that --privileged does not work with Dockerfiles, see [1].
# Thus
# [1] https://github.com/moby/moby/issues/1916

FROM debian:stretch-slim
COPY assets/setup_foreign.sh /
#RUN bash -x /setup_foreign.sh # Sadly this requires --privileged
