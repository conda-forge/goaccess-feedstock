#!/usr/bin/env bash

set -x

./configure \
  --disable-debug \
  --disable-dependency-tracking \
  --enable-utf8 \
  --enable-geoip=mmdb \
  --prefix="$PREFIX"

make bin2c

# bin2c is used during build, so has to be built for the build_platform
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    export CC=$CC_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}

    rm bin2c src/bin2c.o
    $CC -c -o src/bin2c.o src/bin2c.c
    $CC -o bin2c src/bin2c.o
    ./bin2c || true
  )
fi

make
make install
