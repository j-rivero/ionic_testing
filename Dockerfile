FROM ubuntu:noble AS ionic-prerelease
ENV LANG C
ENV LC_ALL C
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y dirmngr curl git python3 python3-docopt python3-yaml python3-distro sudo mesa-utils \
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

FROM ionic-prerelease AS ionic-prerelease-rolling
RUN cd gzdev \
    && python3 gzdev.py repository enable ros2 main
RUN apt-get update \
    && apt-get install -y ros-dev-tools ros-rolling-ros-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN rosdep init
USER ubuntu
WORKDIR /home/ubuntu
RUN mkdir -p ws/src
WORKDIR /home/ubuntu/ws/src
RUN vcs import --input https://raw.githubusercontent.com/gazebo-tooling/gz_vendor/main/gz_vendor.repos
RUN git clone https://github.com/gazebosim/ros_gz
RUN git clone https://github.com/ros-controls/gz_ros2_control
USER root
RUN rosdep update
RUN apt-get update \
    && rosdep install --from-paths . --ignore-src -r --rosdistro rolling -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER ubuntu
WORKDIR /home/ubuntu/ws
RUN . /opt/ros/rolling/setup.sh \
      && MAKEFLAGS=-j6 colcon build
