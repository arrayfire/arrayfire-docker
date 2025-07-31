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

## oneAPI (sh installer)
RUN wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/bd1d0273-a931-4f7e-ab76-6a2a67d646c7/intel-oneapi-base-toolkit-2025.2.0.592.sh && \
    sh ./intel-oneapi-base-toolkit-2025.2.0.592.sh -a --silent --cli --eula accept && \
    rm intel-oneapi-base-toolkit-2025.2.0.592.sh
