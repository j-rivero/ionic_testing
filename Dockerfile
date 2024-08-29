FROM ubuntu:noble AS ionic-prerelease
ENV LANG C
ENV LC_ALL C
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y dirmngr git python3 python3-docopt python3-yaml python3-distro \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/gazebo-tooling/gzdev \
    && cd gzdev \
    && python3 gzdev.py repository enable osrf stable \
    && python3 gzdev.py repository enable osrf prerelease 
RUN apt-get install -y gz-ionic \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM ionic-prerelease AS ionic-nightly
RUN cd gzdev \
    && python3 gzdev.py repository enable osrf nightly
RUN apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
