#!/bin/bash

if [ ${AF_CUDA_MAJOR_VERSION} -eq 12 ]; then
    if [ ${AF_CUDA_MINOR_VERSION} -lt 4 ]; then
        source /opt/rh/gcc-toolset-12/enable
    elif [ ${AF_CUDA_MINOR_VERSION} -lt 8 ]; then
        source /opt/rh/gcc-toolset-13/enable
    fi
fi


function getLibrary {
    find $1 -name $2.so* -exec cp -P "{}" /tmp \;
    find /tmp -type f -name $2.so* -exec patchelf --set-rpath '$ORIGIN' "{}" \;
    echo "`find /tmp -name $2.so* | xargs |  awk '{ gsub(\" \",\";\",$0); print $0 }'`;"
}

function getFile {
    echo "`find $1 -name $2 | xargs |  awk '{ gsub(\" \",\";\",$0); print $0 }'`;"
}

set -e
set -x

use_oneapi=ON
with_graphics=ON
build_cpu=ON
build_cuda=ON
build_oneapi=ON
build_opencl=ON
build_type="RelWithDebInfo"
compute_library_cmake_flag="-DAF_COMPUTE_LIBRARY=Intel-MKL"
sycl_compiler_cmake_flags=""

distro=$(paste -d "_" <(cat /etc/*release | grep "^NAME=" | head -n 1 | cut -d '"' -f 2) <(cat /etc/*release | grep "^VERSION_ID=" | head -n 1 | cut -d '"' -f 2))
build_dir=build_$distro

AF_CUDA_arch_build_targets="5.0;5.2;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0;9.0+PTX"

LONGOPTIONS=no-gl,build-type:,no-mkl,no-cpu,no-cuda,no-oneapi,no-opencl,package-type:,cuda-arch:,intel-compiler:
PARSED=$(getopt --options="" --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi

eval set -- "$PARSED"

while true; do
    case "$1" in
        --no-gl)
            with_graphics=OFF
            shift
            ;;
        --build-type)
            build_type="$2"
            shift 2
            ;;
        --no-mkl)
            use_oneapi=OFF
            build_oneapi=OFF
            compute_library_cmake_flag="-DAF_COMPUTE_LIBRARY=FFTW/LAPACK/BLAS -DBLA_VENDOR=OpenBLAS"
            shift
            ;;
        --no-cpu)
            build_cpu=OFF
            shift
            ;;
        --no-cuda)
            build_cuda=OFF
            shift
            ;;
        --no-oneapi)
            build_oneapi=OFF
            shift
            ;;
        --no-opencl)
            build_opencl=OFF
            shift
            ;;
        --package-type)
            package_type="$2"
            shift 2
            ;;
        --cuda-arch)
            AF_CUDA_arch_build_targets="$2"
            shift 2
            ;;
        --intel-compiler)
            intel_cmplr_root="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

cd /usr/src

if [[ ! -d arrayfire/ ]]; then
    git clone --recursive https://github.com/arrayfire/arrayfire
    cd arrayfire
    git config user.email "installer@docker.xyz"
    git config user.name "Installer Builder"
else
    cd arrayfire
    git pull
fi

mkdir -p "$build_dir"
cd "$build_dir"

if [ "$use_oneapi" = "ON" ]; then
    set +x
    source ${intel_cmplr_root}/oneapi/setvars.sh
    set -x
    compute_library_cmake_flag+=" -DAF_ADDITIONAL_MKL_LIBRARIES:FILEPATHS="
    compute_library_cmake_flag+=$(getLibrary $TBBROOT libtbb)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libimf)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libsycl)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libsvml)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libirng)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libintlc)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libur_loader)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libur_adapter_opencl)
    compute_library_cmake_flag+=$(getLibrary $TCM_ROOT/lib libhwloc)
    compute_library_cmake_flag+=$(getLibrary $CMPLR_ROOT/lib libintelocl)
    compute_library_cmake_flag+=$(getLibrary $UMF_ROOT/lib libumf)

    sycl_compiler_cmake_flags+=" -DCMAKE_SYCL_COMPILER=icpx \'-DCMAKE_SYCL_FLAGS=-fsycl -D_GLIBCXX_USE_CXX11_ABI=1\'"
fi

# Look for correct OpenCL library and headers, location depends on the distro
for ocl in "/usr/lib64/libOpenCL.so.1" "/usr/lib/x86_64-linux-gnu/libOpenCL.so.1"; do
    if [ -f "$ocl" ]; then ocl_dir=$ocl; break; fi
done
if [ -z "$ocl_dir" ]; then
    echo "Couldn't find OpenCL library!"
    exit 1
else
    opencl_library_cmake_flag=" -DOpenCL_LIBRARY=$ocl_dir -DOPENCL_LIBRARIES=$ocl_dir"
fi
opencl_include_cmake_flag=" -DOPENCL_INCLUDE_DIRS=${OCL_ROOT}/include -DOpenCL_INCLUDE_DIR=${OCL_ROOT}/include"

cmake -G Ninja                                                                               \
      -DCMAKE_BUILD_TYPE:STRING="$build_type"                                                \
      -DFG_USE_STATIC_CPPFLAGS:BOOL=OFF                                                      \
      -DAF_WITH_STATIC_CUDA_NUMERIC_LIBS=OFF                                                 \
      -DFG_WITH_FREEIMAGE:BOOL=ON                                                            \
      $compute_library_cmake_flag                                                            \
      -DAF_BUILD_CPU:BOOL="$build_cpu"                                                       \
      -DAF_BUILD_DOCS:BOOL=ON                                                                \
      -DAF_BUILD_EXAMPLES:BOOL=OFF                                                           \
      -DAF_BUILD_ONEAPI:BOOL="$build_oneapi"                                                 \
      -DAF_BUILD_CUDA:BOOL="$build_cuda"                                                     \
      -DAF_BUILD_OPENCL:BOOL="$build_opencl"                                                 \
      -DAF_BUILD_FORGE:BOOL=$with_graphics                                                   \
      $sycl_compiler_cmake_flags                                                             \
      -DAF_WITH_IMAGEIO:BOOL=ON                                                              \
      -DAF_WITH_LOGGING:BOOL=ON                                                              \
      -DAF_INSTALL_STANDALONE:BOOL=ON                                                        \
      -DAF_WITH_SPDLOG_HEADER_ONLY=ON                                                        \
      -DAF_WITH_FMT_HEADER_ONLY=ON                                                           \
      -DBUILD_TESTING:BOOL=OFF                                                               \
      -DCUDA_architecture_build_targets:STRING=$AF_CUDA_arch_build_targets                   \
      $opencl_library_cmake_flag                                                             \
      $opencl_include_cmake_flag                                                             \
      ..

# This may need to be adjusted depending on how much memory your system has.
# oneAPI backend compilation uses a lot.
#cmake --build . -- -v
cmake --build . -j 8 -- -v

cpack -G "$package_type"

