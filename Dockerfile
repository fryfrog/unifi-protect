FROM phusion/baseimage:0.11
MAINTAINER pducharme@me.com

# Version
ENV version 3.10.2

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Add mongodb repo, key, update and install needed packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 97B46B8582C6571E && \
  apt-add-repository https://apt.ubnt.com && \
  apt-get update && \
  apt-get install -y apt-utils && \
  apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
  apt-get install -y  \
    moreutils \
    patch \
    sudo \
    tzdata \
    unifi-protect \
    moreutils \
    wget

# Add needed patches and scripts
ADD run.sh /run.sh
RUN chmod 755 /run.sh && \
  usermod --shell /bin/bash unifi-protect

# Ports
EXPOSE 7080/tcp 7443/tcp 7444/tcp 7447/tcp 7550/tcp 7442/tcp

# Video storage volume
VOLUME ["/srv/unifi-protect"]

# Run this potato
CMD ["/run.sh"]
