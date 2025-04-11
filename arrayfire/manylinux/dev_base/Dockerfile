FROM quay.io/pypa/manylinux_2_28_x86_64
MAINTAINER Christophe Murphy <christophe@arrayfire.com>
RUN dnf update -y && \
    dnf groupinstall -y "Development Tools" && \
    dnf -y install ocl-icd ocl-icd-devel opencl-headers \
           wget freetype-devel fontconfig-devel \
           fftw-devel openblas-devel lapack-devel \
           glfw-devel graphviz graphviz-devel \
           mesa-libGLU-devel freeimage-devel && \
    dnf clean all

# Set location for OpenCL library
ENV OCL_ROOT /usr
ENV OPENCL_ROOT /usr

# Ninja build system
RUN cd /usr/src && \
    git clone https://github.com/ninja-build/ninja.git && \
    cd ninja && \
    git checkout v1.12.1 && \
    ./configure.py --bootstrap && \
    mv ninja /usr/bin/ && \
    cd .. && rm -rf ninja
