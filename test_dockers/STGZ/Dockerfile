FROM nvidia/cuda:12.8.1-base-ubuntu22.04

RUN apt update && apt-get -y install nvidia-compute-utils-570 wget clinfo build-essential cmake

RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
    apt update && apt-get -y install intel-oneapi-runtime-opencl intel-oneapi-compiler-dpcpp-cpp-runtime

COPY ArrayFire-3.10.0-Linux.sh /usr/src

RUN cd /usr/src && ./ArrayFire-3.10.0-Linux.sh --skip-license && rm ArrayFire-3.10.0-Linux.sh

RUN cd /usr/src/share/ArrayFire/examples && mkdir build && cd build && \
    . /opt/intel/oneapi/setvars.sh && \
    cmake -DArrayFire_DIR=/usr/src/share/ArrayFire/cmake .. && make -j 14

RUN echo '\n\
# Source the runtime so we can run oneapi back end\n\
. /opt/intel/oneapi/setvars.sh' >> /etc/bash.bashrc
