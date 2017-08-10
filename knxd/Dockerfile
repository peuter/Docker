# Build the knxd Docker container
# 
# note: debian:jessie is not the smallest possible environment - but as it
# is expected that also an Apache with PHP is run the same environment was
# chosen to have an overall optimization.
# An obvious choice for a smaller enviroment could be e.g. debian:stable-slim

FROM debian:jessie as builder
MAINTAINER Christian Mayer docker@cometvisu.org

ENV BUILD_PACKAGES \
  autoconf \
  automake \
  autotools-dev \
  build-essential \
  debhelper \
  dh-systemd \
  git-core \
  libev-dev \
  libsystemd-daemon-dev \
  libsystemd-dev \
  libtool \
  libusb-1.0-0-dev \
  pkg-config

RUN apt-get update && apt-get -y install $BUILD_PACKAGES

# build knxd

RUN git clone https://github.com/knxd/knxd.git && cd knxd && git checkout tags/v0.12.16 && \
    dpkg-buildpackage -b -uc

# install in a fresh and thus clean environment
#

FROM debian:jessie

COPY --from=builder /knxd_*.deb /knxd-tools_*.deb ./
RUN apt-get update && apt-get -y install libev4 libusb-1.0-0 init-system-helpers
RUN dpkg -i knxd_*.deb knxd-tools_*.deb

# needs fix for socket exposure on volume with root<->user first
#RUN groupadd -r knxduser && useradd --no-log-init -r -g knxduser knxduser
#USER knxduser

EXPOSE 6720

# debug
RUN echo SOURCE_BRANCH
RUN echo $SOURCE_COMMIT
RUN echo $COMMIT_MSG
RUN echo $DOCKER_REPO
RUN echo $CACHE_TAG
RUN echo $IMAGE_NAME
# debug

CMD  ["knxd"]
