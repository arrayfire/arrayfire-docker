FROM af/ubuntu/dependencies
MAINTAINER Christophe Murphy <christophe@arrayfire.com>

ARG AF_CUDA_VERSION

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && apt-get update -y && \
    apt-get -y install cuda-toolkit-${AF_CUDA_VERSION} && \
    apt-get -y install cudnn9-cuda-${AF_CUDA_VERSION} && \
    apt-get clean -y && rm -rf cuda-keyring_1.1-1_all.deb

# Create Nvidia's ICD and missing standard simlink for CUDA stub library
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "/usr/local/cuda/targets/x86_64-linux/lib/libOpenCL.so" > /etc/OpenCL/vendors/nvidia.icd && \
    ldconfig && \
    ln -s /usr/local/cuda-12.8/targets/x86_64-linux/lib/stubs/libcuda.so \
          /usr/local/cuda-12.8/targets/x86_64-linux/lib/stubs/libcuda.so.1

ENV PATH /usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:${LD_LIBRARY_PATH}
