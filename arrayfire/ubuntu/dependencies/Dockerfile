FROM af/ubuntu/dev_base
MAINTAINER Christophe Murphy <christophe@arrayfire.com>

RUN apt-get update -y

# Boost
RUN apt-get install -y libboost-all-dev

# Doxygen
RUN apt-get install -y graphviz libgraphviz-dev flex bison
RUN cd /usr/src && \
    git clone -b Release_1_13_2 https://github.com/doxygen/doxygen.git && \
    cd doxygen && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && \
    make -j$(grep -c processor /proc/cpuinfo) install && \
    cd /usr/src && rm -rf doxygen

# oneAPI
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    | tee /etc/apt/sources.list.d/oneAPI.list && \
    apt-get update -y && apt-get install -y intel-oneapi-base-toolkit

RUN apt-get clean -y
