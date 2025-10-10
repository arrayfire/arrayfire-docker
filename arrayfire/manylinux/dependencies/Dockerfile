FROM af/manylinux/dev_base
MAINTAINER Christophe Murphy <christophe@arrayfire.com>

# Boost
FROM af/manylinux/dev_base as boost
RUN cd /usr/src && \
    wget https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.gz && \
    tar -xvzf boost_1_87_0.tar.gz && \
    cd boost_1_87_0 && \
    ./bootstrap.sh --prefix=/artifact && \
    ./b2 install && \
    cd /usr/src && rm -rf boost_1_87_0*

# Doxygen
FROM af/manylinux/dev_base as doxygen
RUN cd /usr/src && \
    git clone -b Release_1_13_2 https://github.com/doxygen/doxygen.git && \
    cd doxygen && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/artifact .. && \
    make -j$(grep -c processor /proc/cpuinfo) install && \
    cd /usr/src && rm -rf doxygen

FROM af/manylinux/dev_base
MAINTAINER Christophe Murphy <christophe@arrayfire.com>

# Boost
COPY --from=boost /artifact /usr
# Doxgyen
COPY --from=doxygen /artifact /usr

# oneAPI
RUN echo $'[oneAPI]\n\
name=Intel® oneAPI repository\n\
baseurl=https://yum.repos.intel.com/oneapi\n\
enabled=1\n\
gpgcheck=1\n\
repo_gpgcheck=1\n\
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB' > /etc/yum.repos.d/oneAPI.repo && \
cat /etc/yum.repos.d/oneAPI.repo && \
dnf -y update && dnf -y install intel-oneapi-base-toolkit && dnf clean all
