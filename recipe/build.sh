#!/usr/bin/env bash

echo "\n\n============================================"
env
echo "============================================\n\n"


if [[ $build_platform != $target_platform ]] && [[ "$mpi" == "openmpi" ]]; then
    # enable cross compiling with openmpi
    cp -rf $PREFIX/share/openmpi/*.txt $BUILD_PREFIX/share/openmpi/
fi

autoreconf -vfi

export CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math"

CONFIGURE="./configure --prefix=$PREFIX --with-pic --enable-threads"

if [[ "$mpi" != "nompi" ]]; then
    CONFIGURE="${CONFIGURE} --enable-mpi"
fi

CONFIGURE=${CONFIGURE}" --enable-openmp"

# (Note exported LDFLAGS and CFLAGS vars provided above.)
BUILD_CMD="make -j${CPU_COUNT}"
INSTALL_CMD="make install"

# Test suite
# tests are performed during building as they are not available in the
# installed package.
# Additional tests can be run with "make smallcheck" and "make bigcheck"
CHECK_KIND="check-local"
if [[ "$target_platform" == "linux-ppc64le" ]]; then
    CHECK_KIND="smallcheck"
fi
TEST_CMD="eval cd tests && make ${CHECK_KIND} && cd -"

#
# We build 3 different versions of fftw:
#
if [[ "$target_platform" == "linux-64" ]] || [[ "$target_platform" == "linux-32" ]] || [[ "$target_platform" == "osx-64" ]]; then
  ARCH_OPTS_SINGLE="--enable-sse --enable-sse2 --enable-avx"
  ARCH_OPTS_DOUBLE="--enable-sse2 --enable-avx"
  ARCH_OPTS_LONG_DOUBLE=""
fi

if [[ "$target_platform" == "linux-ppc64le" ]]; then
  # ARCH_OPTS_SINGLE="--enable-vsx"                        # VSX SP disabled as results in test fails. See https://github.com/FFTW/fftw3/issues/59
  ARCH_OPTS_SINGLE="--enable-silent-rules"                 # enable-silent rules to avoid Travis CI log overflow
  ARCH_OPTS_DOUBLE="--enable-vsx --enable-silent-rules"
  ARCH_OPTS_LONG_DOUBLE="--enable-silent-rules"

  # Disable Tests since we don't have enough time on Azure
  #   if [[ "$CI" == "azure" ]]; then
  #     TEST_CMD=""
  #   fi
fi

if [[ "$target_platform" == "linux-aarch64" ]]; then
  # ARCH_OPTS_SINGLE="--enable-neon"                       # Neon disabled for now
  ARCH_OPTS_SINGLE=""
  #ARCH_OPTS_DOUBLE="--enable-neon"                        # Neon disabled for now
  ARCH_OPTS_DOUBLE=""
  ARCH_OPTS_LONG_DOUBLE=""

  # Disable Tests since we don't have enough time on Drone
  if [[ "$CI" == "drone" ]]; then
    TEST_CMD=""
  fi
fi

if [[ "$target_platform" == "osx-arm64" ]]; then
  ARCH_OPTS_SINGLE="--enable-neon"
  ARCH_OPTS_DOUBLE="--enable-neon"
  DISABLE_LONG_DOUBLE=1
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == 1 && "${CROSSCOMPILING_EMULATOR:-}" == "" ]]; then
  TEST_CMD=""
fi

build_cases=(
    # single
    "$CONFIGURE --enable-float ${ARCH_OPTS_SINGLE}"
    # double
    "$CONFIGURE ${ARCH_OPTS_DOUBLE}"
)

if [[ "$DISABLE_LONG_DOUBLE" != 1 ]]; then
    # long double (SSE2 and AVX not supported)
    build_cases+=("$CONFIGURE --enable-long-double ${ARCH_OPTS_LONG_DOUBLE}")
fi

echo "\n\n============================================"
echo "test command: ${TEST_CMD}"
echo "============================================\n\n"

# first build shared objects
for config in "${build_cases[@]}"
do
    :
    $config --enable-shared --disable-static
    ${BUILD_CMD}
    ${INSTALL_CMD}
    ${TEST_CMD}
done

# now build static libraries without exposing fftw* symbols in downstream shared objects
for config in "${build_cases[@]}"
do
    :
    $config --disable-shared --enable-static CFLAGS="${CFLAGS} -fvisibility=hidden"
    ${BUILD_CMD}
    ${INSTALL_CMD}
    ${TEST_CMD}
done
