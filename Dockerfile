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
RUN git clone https://github.com/turtlebot/turtlebot4_simulator.git -b jazzy
RUN git clone https://github.com/iRobotEducation/create3_sim -b jazzy
RUN git clone https://github.com/turtlebot/turtlebot4_desktop.git -b jazzy
RUN rosdep update \
    && rosdep install --from-paths . --ignore-src -r --rosdistro ${ROS_DISTRO} -y
WORKDIR /home/ubuntu/ws
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
      && MAKEFLAGS=-j6 colcon build
