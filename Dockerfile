FROM ubuntu:18.04
LABEL maintainer="fryfrog"

ARG DEBIAN_FRONTEND="noninteractive"
ARG ARCH_S6="amd64"

# Set correct environment variables
ENV version 1.12.5
ENV APP_DIR="/srv/unifi-protect" CONFIG_DIR="/config" PUID="999" PGID="999" PUID_POSTGRES="102" PGID_POSTGRES="104" UMASK="002" VERSION="none"
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

# Ports
EXPOSE 7080/tcp 7443/tcp 7444/tcp 7447/tcp 7550/tcp 7442/tcp

# Video storage volume
VOLUME ["/srv/unifi-protect"]

# Setup the S6 overlay and update/install packages
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
  apt-get update && \
  apt-get install -y apt-utils locales && \
  locale-gen en_US.UTF-8 && \
  apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
  apt-get install -y  \
    curl \
    dbus \
    moreutils \
    patch \
    sudo \
    tzdata \
    moreutils \
    nodejs \
    psmisc \
    sudo \
    systemd \
    wget && \
    wget --quiet https://apt.ubnt.com/pool/beta/u/unifi-protect/unifi-protect.jessie~stretch~xenial~bionic_amd64.v${version}.deb && \
    apt install -y ./unifi-protect.jessie~stretch~xenial~bionic_amd64.v${version}.deb

# Add needed patches and scripts
COPY root/ /

# Run this potato
ENTRYPOINT ["/init"]
