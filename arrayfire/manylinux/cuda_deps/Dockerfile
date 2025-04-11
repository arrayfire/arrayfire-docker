FROM af/manylinux/dependencies
MAINTAINER Christophe Murphy <christophe@arrayfire.com>

ARG AF_CUDA_VERSION

RUN dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo && \
    dnf clean all && \
    dnf -y install cuda-toolkit-${AF_CUDA_VERSION} && \
    dnf -y install cudnn-cuda-${AF_CUDA_VERSION} && \
    dnf clean all

# Create Nvidia's ICD and missing standard simlinks for the CUDA driver and OpenCL
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "/usr/local/cuda/targets/x86_64-linux/lib/libOpenCL.so" > /etc/OpenCL/vendors/nvidia.icd && \
    ldconfig && \
    ln -s /usr/local/cuda-12.8/targets/x86_64-linux/lib/stubs/libcuda.so \
          /usr/local/cuda-12.8/targets/x86_64-linux/lib/stubs/libcuda.so.1

ENV PATH /usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:${LD_LIBRARY_PATH}
