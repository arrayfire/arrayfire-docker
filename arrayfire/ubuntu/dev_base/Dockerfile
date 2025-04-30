ARG UBUNTU_LTS_VERSION

FROM ubuntu:$UBUNTU_LTS_VERSION
MAINTAINER Christophe Murphy <christophe@arrayfire.com>
RUN apt-get update -y && \
    apt-get install -y wget build-essential git \
                       libopenblas-dev libfftw3-dev \
                       libfreetype-dev libfontconfig-dev \
                       liblapacke-dev ocl-icd-opencl-dev \
                       opencl-headers libglfw3-dev \
                       libfreeimage-dev libglu1-mesa-dev

# Set location for OpenCL library
ENV OCL_ROOT=/usr

# CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' \
    | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt-get update -y && apt-get install -y cmake

RUN apt-get clean -y

# Ninja build system
RUN cd /usr/src && \
    git clone https://github.com/ninja-build/ninja.git && \
    cd ninja && \
    git checkout v1.12.1 && \
    ./configure.py --bootstrap && \
    mv ninja /usr/bin/ && \
    cd .. && rm -rf ninja
