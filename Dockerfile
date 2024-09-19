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

FROM ionic-prerelease AS ionic-turtlebot4
ENV ROS_DISTRO jazzy
RUN cd gzdev \
    && python3 gzdev.py repository enable ros2 main
RUN apt-get update \
    && apt-get install -y ros-dev-tools ros-${ROS_DISTRO}-ros-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN rosdep init
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
RUN apt-get update  # ready for rosdep
USER ubuntu
WORKDIR /home/ubuntu
RUN mkdir -p ws/src
WORKDIR /home/ubuntu/ws/src
RUN git clone https://github.com/turtlebot/turtlebot4 -b jazzy
RUN git clone https://github.com/j-rivero/turtlebot4_simulator.git -b jazzy
RUN git clone https://github.com/j-rivero/create3_sim -b jazzy
RUN git clone https://github.com/turtlebot/turtlebot4_desktop.git -b jazzy
RUN git clone https://github.com/gazebosim/ros_gz.git -b ros2
RUN curl https://gist.githubusercontent.com/azeey/a94adb591475ea0e613313d3540ca451/raw/2bb0a92f327816279514aca9ff4079a5d523f7aa/gz_vendor.repos -o gz_vendor.repos
RUN vcs import . < gz_vendor.repos
RUN colcon list
ENV GZ_RELAX_VERSION_MATCH 1
RUN rosdep update \
   && rosdep install --from-paths . --ignore-src -r --rosdistro ${ROS_DISTRO} -y
# Remove vendor packages (Harmonic)
RUN sudo apt-get remove ros-jazzy-gz-*-vendor
# Workaround for https://github.com/gazebosim/gz-msgs/issues/46# Workaround for https://github.com/gazebosim/gz-msgs/issues/463
RUN sudo sed -i -e 's:PROTOBUF_DEPRECATED_ENUM::' /usr/include/gz/msgs11/gz/msgs/details/spherical_coordinates.pb.h
WORKDIR /home/ubuntu/ws
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
     && MAKEFLAGS=-j6 colcon build
