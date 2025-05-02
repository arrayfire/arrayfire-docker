#!/bin/bash


#set up opencl
cd /usr/src
if [[ ! -d OpenCL-Headers/ ]]; then
git clone https://github.com/KhronosGroup/OpenCL-Headers.git
fi
cd /usr/src/OpenCL-Headers
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build --target install -j

cd /usr/src
if [[ ! -d OpenCL-CLHPP/ ]]; then
git clone https://github.com/KhronosGroup/OpenCL-CLHPP.git
fi
cd /usr/src/OpenCL-CLHPP
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
cmake --build build --target install -j

#build wrapper
python$AF_PYTHON_VERSION -m pip uninstall -y arrayfire*

cd /usr/src
if [[ ! -d arrayfire-binary-python-wrapper/ ]]; then
git clone https://github.com/edwinsolisf/arrayfire-binary-python-wrapper.git --branch afwheel310
fi
cd /usr/src/arrayfire-binary-python-wrapper
git pull origin afwheel310
source /opt/intel/oneapi/setvars.sh
export AF_BUILD_LOCAL_LIBS=1
python$AF_PYTHON_VERSION -m pip install -r requirements.txt

CMAKE_ARGS="-DAF_BUILD_OPENCL=$AF_BUILD_OPENCL -DAF_BUILD_CUDA=$AF_BUILD_CUDA -DAF_BUILD_ONEAPI=$AF_BUILD_ONEAPI -DAF_COMPUTE_LIBRARY=$AF_COMPUTE_LIBRARY \
-DAF_BUILD_FORGE=$AF_BUILD_FORGE -DAF_WITH_STATIC_CUDA_NUMERIC_LIBS=$AF_WITH_STATIC_CUDA_NUMERIC_LIBS -DAF_WITH_IMAGEIO=$AF_WITH_IMAGEIO \
-DCUDA_architecture_build_targets=$AF_CUDA_ARCHITECTURES -DFG_USE_STATIC_CPPFLAGS=$FG_USE_STATIC_CPPFLAGS -DFG_WITH_FREEIMAGE=$FG_WITH_FREEIMAGE" python$AF_PYTHON_VERSION -m build --wheel -v

#test wrapper
python$AF_PYTHON_VERSION -m pip install dist/arrayfire_binary_python_wrapper-0.8.0+af3.10.0-py3-none-linux_x86_64.whl
cd /usr/src
if [[ ! -d arrayfire-py/ ]]; then
git clone https://github.com/edwinsolisf/arrayfire-py.git --branch afwheel310
fi
cd /usr/src/arrayfire-py
git pull origin afwheel310
python$AF_PYTHON_VERSION -m pip install -r requirements.txt
python$AF_PYTHON_VERSION -m build --wheel -v
python$AF_PYTHON_VERSION -m pip install dist/arrayfire*
python$AF_PYTHON_VERSION -m pytest