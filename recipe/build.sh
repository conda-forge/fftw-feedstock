#!/usr/bin/env bash

# Depending on our platform, shared libraries end with either .so or .dylib
declare -a PLATFORM_CONFIG
if [[ `uname` == 'Darwin' ]]; then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export DYLIB_EXT=dylib
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="-stdlib=libc++"
    export CXX_LDFLAGS="-stdlib=libc++"
    PLATFORM_CONFIG+=(--with-pic)
elif [[ `uname` == 'Linux' ]]; then
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
    export DYLIB_EXT=so
    export CC=gcc
    export CXX=g++
    PLATFORM_CONFIG+=(--with-pic)
elif [[ `uname -o` == 'Msys' ]]; then
    export LIBRARY_SEARCH_VAR=not_needed
    export DYLIB_EXT=dll
    export CC=gcc
    export CXX=g++
    PLATFORM_CONFIG+=(--with-our-malloc)
    if [[ ${ARCH} == 32 ]]; then
        PLATFORM_CONFIG+=(--host=i686-w64-mingw32)
    else
        PLATFORM_CONFIG+=(--host=x86_64-w64-mingw32)
    fi
fi

export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"

CONFIGURE="./configure --prefix=$PREFIX --enable-shared --enable-threads --disable-fortran ${PLATFORM_CONFIG[@]}"

# (Note exported LDFLAGS and CFLAGS vars provided above.)
BUILD_CMD="make -j${CPU_COUNT}"
INSTALL_CMD="make install"

# Test suite
# tests are performed during building as they are not available in the
# installed package.
# Additional tests can be run with "make smallcheck" and "make bigcheck"
if [[ `uname -o` == 'Msys' ]]; then
  TEST_CMD="echo skipping test on Windows due to path conversion"
else
  TEST_CMD="eval cd tests && ${LIBRARY_SEARCH_VAR}=\"$PREFIX/lib\" make check-local && cd -"
fi

#
# We build 3 different versions of fftw:
#
build_cases=(
    # single
    "$CONFIGURE --enable-float --enable-sse --enable-sse2 --enable-avx"
    # double
    "$CONFIGURE --enable-sse2 --enable-avx"
    # long double (SSE2 and AVX not supported)
    "$CONFIGURE --enable-long-double"
)

for config in "${build_cases[@]}"
do
    :
    $config
    ${BUILD_CMD}
    ${INSTALL_CMD}
    ${TEST_CMD}
done

unset LIBRARY_SEARCH_VAR
unset DYLIB_EXT
unset CC
unset CXX
unset CXXFLAGS
unset CXX_LDFLAGS
unset LDFLAGS
unset CFLAGS
