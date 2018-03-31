#!/bin/bash

oggurl=http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
vorbisurl=http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz

oggfile=${oggurl##*/}
vorbisfile=${vorbisurl##*/}

cwd=$PWD

export CFLAGS="-arch i386 -arch x86_64 -mmacosx-version-min=10.8"

export MAKE="xcrun make"
export CC="xcrun clang"
export CXX="xcrun clang++"
export LD="xcrun ld"
export AR="xcrun ar"
export RANLIB="xcrun ranlib"
export STRIP="xcrun strip"
export OTOOL="xcrun otool"
export LIPO="xcrun lipo"
export NM="xcrun nm"
export NMEDIT="xcrun nmedit"
export DSYMUTIL="xcrun dsymutil"

check_tools() {
    echo "+++ Checking build tools"
    if ! xcrun -f make &>/dev/null; then
        echo "Error: could not execute 'make'. Giving up."
        exit 1
    fi
}

if test ! -f out/lib/libogg.a; then
    check_tools

    rm -rf libogg-build
    mkdir libogg-build

    echo "+++ Fetching and unpacking $oggurl"
    test ! -f $oggfile && curl -L -s $oggurl -o $oggfile
    (cd libogg-build; tar zx --strip-components 1) < $oggfile || exit

    echo "+++ Configuring libogg"
    (cd libogg-build; PKG_CONFIG=false ./configure --prefix=$cwd/out) || exit

    echo "+++ Building libogg"
    (cd libogg-build; $MAKE) || exit

    echo "+++ Collecting libogg build products"
    (cd libogg-build; $MAKE install)

    echo "+++ Cleaning up libogg"
    rm -rf libogg-build
fi

if test ! -f out/lib/libvorbisfile.a; then
    check_tools

    rm -rf libvorbis-build
    mkdir libvorbis-build

    echo "+++ Fetching and unpacking $vorbisurl"
    test ! -f $vorbisfile && curl -L -s $vorbisurl -o $vorbisfile
    (cd libvorbis-build; tar zx --strip-components 1) < $vorbisfile || exit

    echo "+++ Configuring libvorbis"
    (cd libvorbis-build; PKG_CONFIG=false ./configure --with-ogg=$cwd/out --prefix=$cwd/out) || exit

    echo "+++ Building libvorbis"
    (cd libvorbis-build; $MAKE) || exit

    echo "+++ Collecting libvorbis build products"
    (cd libvorbis-build; $MAKE install)

    echo "+++ Cleaning up libvorbis"
    rm -rf libvorbis-build
fi
