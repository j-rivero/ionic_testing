FROM ubuntu:noble AS ionic-prerelease
ENV LANG C
ENV LC_ALL C
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y dirmngr git python3 python3-docopt python3-yaml python3-distro sudo mesa-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/gazebo-tooling/gzdev \
    && cd gzdev \
    && python3 gzdev.py repository enable osrf stable \
    && python3 gzdev.py repository enable osrf prerelease 
RUN apt-get install -y gz-ionic \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM ionic-prerelease AS ionic-prerelease-nvidia
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
        libxau6 libxau6:i386 \
        libxdmcp6 libxdmcp6:i386 \
        libxcb1 libxcb1:i386 \
        libxext6 libxext6:i386 \
        libx11-6 libx11-6:i386 \
        libglvnd0 libglvnd0:i386 \
        libgl1 libgl1:i386 \
        libglx0 libglx0:i386 \
        libegl1 libegl1:i386 \
        libgles2 libgles2:i386 && \
    rm -rf /var/lib/apt/lists/*
COPY 10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
        ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
        ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
# Required for non-glvnd setups.
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

FROM ionic-prerelease AS ionic-nightly
RUN cd gzdev \
    && python3 gzdev.py repository enable osrf nightly
RUN apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
