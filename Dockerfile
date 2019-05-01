FROM phusion/baseimage:0.11
MAINTAINER fryfrog@gmail.com

# Version
ENV version 1.10.0

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Add mongodb repo, key, update and install needed packages
RUN apt-get update && \
  apt-get install -y apt-utils && \
  apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
  apt-get install -y  \
    moreutils \
    patch \
    sudo \
    tzdata \
    moreutils \
    wget && \
  wget --quiet http://apt.ubnt.com/pool/beta/u/unifi-protect/unifi-protect.jessie~stretch~xenial~bionic_amd64.v1.10.0-beta.5.deb && \
  apt install -y ./unifi-protect.jessie~stretch~xenial~bionic_amd64.v1.10.0-beta.5.deb

# Add needed patches and scripts
ADD run.sh /run.sh
RUN chmod 755 /run.sh && \
  usermod --shell /bin/bash unifi-protect

# Ports
EXPOSE 7080/tcp 7443/tcp 7444/tcp 7447/tcp 7550/tcp 7442/tcp

# Video storage volume
VOLUME ["/srv/unifi-protect", "/var/lib/postgresql/10/main"]

# Run this potato
CMD ["/run.sh"]
