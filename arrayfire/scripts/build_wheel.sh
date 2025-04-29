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
export CMAKE_BUILD_PARALLEL_LEVEL=3
python$AF_PYTHON_VERSION -m pip install -r requirements.txt
python$AF_PYTHON_VERSION -m build --wheel -v

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