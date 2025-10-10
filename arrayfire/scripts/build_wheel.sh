#!/bin/bash

function getLibrary {
    find $1 -name $2.so* -exec cp "{}" /tmp \;
    find /tmp -name $2.so* -exec patchelf --set-rpath '$ORIGIN' "{}" \;
    echo "`find /tmp -name $2.so* | xargs |  awk '{ gsub(\" \",\";\",$0); print $0 }'`;"
}

function getFile {
    echo "`find $1 -name $2 | xargs |  awk '{ gsub(\" \",\";\",$0); print $0 }'`;"
}

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

cd /usr/src
if [[ ! -d arrayfire-binary-python-wrapper/ ]]; then
git clone https://github.com/edwinsolisf/arrayfire-binary-python-wrapper.git
fi
cd /usr/src/arrayfire-binary-python-wrapper
git pull origin master

ls /usr/lib64/libcuda.so.1
nvidia-smi

set +x
source /opt/intel/oneapi/setvars.sh
set -x
compute_library_cmake_flag="-DAF_ADDITIONAL_MKL_LIBRARIES:FILEPATHS="
compute_library_cmake_flag+=$(getLibrary $TBBROOT libtbb)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libimf)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libsycl)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libsvml)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libirng)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libintlc)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libur_loader)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libur_adapter_opencl)
compute_library_cmake_flag+=$(getFile $CMPLR_ROOT/lib cl.cfg)
compute_library_cmake_flag+=$(getFile $CMPLR_ROOT/lib clbltfn*.rtl)
compute_library_cmake_flag+=$(getFile $CMPLR_ROOT/lib cllibrary.rtl)
compute_library_cmake_flag+=$(getFile $CMPLR_ROOT/lib cllibrary*.o)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libcommon_clang)
compute_library_cmake_flag+=$(getLibrary $TCM_ROOT/lib libhwloc)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libintelocl)
compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libocl_svml_*)
compute_library_cmake_flag+=$(getLibrary $UMF_ROOT/lib libumf)

python$AF_PYTHON_VERSION -m pip install -r requirements.txt
python$AF_PYTHON_VERSION -m pip install auditwheel

CMAKE_ARGS="-DAF_BUILD_OPENCL=$AF_BUILD_OPENCL -DAF_BUILD_CUDA=$AF_BUILD_CUDA -DAF_BUILD_ONEAPI=$AF_BUILD_ONEAPI -DAF_COMPUTE_LIBRARY=$AF_COMPUTE_LIBRARY \
-DAF_BUILD_FORGE=$AF_BUILD_FORGE -DAF_WITH_STATIC_CUDA_NUMERIC_LIBS=$AF_WITH_STATIC_CUDA_NUMERIC_LIBS -DAF_WITH_IMAGEIO=$AF_WITH_IMAGEIO \
-DCUDA_architecture_build_targets=$AF_CUDA_ARCHITECTURES -DFG_USE_STATIC_CPPFLAGS=$FG_USE_STATIC_CPPFLAGS -DFG_WITH_FREEIMAGE=$FG_WITH_FREEIMAGE \
-DAF_BUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF $compute_library_cmake_flag" python$AF_PYTHON_VERSION -m build --wheel -v
mkdir -p dist_nobin
mv dist/arrayfire_binary_python_wrapper-0.8.0-py3-none-linux_x86_64.whl dist_nobin/

export AF_BUILD_LOCAL_LIBS=1
CMAKE_ARGS="-DAF_BUILD_OPENCL=$AF_BUILD_OPENCL -DAF_BUILD_CUDA=$AF_BUILD_CUDA -DAF_BUILD_ONEAPI=$AF_BUILD_ONEAPI -DAF_COMPUTE_LIBRARY=$AF_COMPUTE_LIBRARY \
-DAF_BUILD_FORGE=$AF_BUILD_FORGE -DAF_WITH_STATIC_CUDA_NUMERIC_LIBS=$AF_WITH_STATIC_CUDA_NUMERIC_LIBS -DAF_WITH_IMAGEIO=$AF_WITH_IMAGEIO \
-DCUDA_architecture_build_targets=$AF_CUDA_ARCHITECTURES -DFG_USE_STATIC_CPPFLAGS=$FG_USE_STATIC_CPPFLAGS -DFG_WITH_FREEIMAGE=$FG_WITH_FREEIMAGE \
-DAF_BUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF $compute_library_cmake_flag" python$AF_PYTHON_VERSION -m build --wheel -v

exclude_flags="--exclude libcuda.so.* --exclude libcudnn_ops.so.* --exclude libcudnn_graph.so.* --exclude libimf.so* --exclude libsvml.so* --exclude libirng.so* --exclude libintlc.so.* --exclude libsycl.so.* --exclude libumf.so.* --exclude libmkl_core.so.*"

python$AF_PYTHON_VERSION -m auditwheel repair $exclude_flags dist/arrayfire_binary_python_wrapper-0.8.0-py3-none-linux_x86_64.whl

cd /usr/src
if [[ ! -d arrayfire-py/ ]]; then
git clone https://github.com/arrayfire/arrayfire-py.git --branch master
fi
cd /usr/src/arrayfire-py
git pull origin master

python$AF_PYTHON_VERSION -m pip install -r requirements.txt
python$AF_PYTHON_VERSION -m build --wheel -v
        
# install packages
python$AF_PYTHON_VERSION -m pip uninstall -y arrayfire-binary-python-wrapper arrayfire-py
python$AF_PYTHON_VERSION -m pip install /usr/src/arrayfire-binary-python-wrapper/wheelhouse/arrayfire_binary_python_wrapper-0.8.0-py3-none-manylinux_2_28_x86_64.whl
python$AF_PYTHON_VERSION -m pip install /usr/src/arrayfire-py/dist/arrayfire-0.1.0-py3-none-any.whl

# run tests
rm /etc/OpenCL/vendors/nvidia.icd

python$AF_PYTHON_VERSION -m pip install numpy
cd /usr/src/arrayfire-binary-python-wrapper 
python$AF_PYTHON_VERSION -m pytest

cd /usr/src/arrayfire-py
python$AF_PYTHON_VERSION -m pytest tests