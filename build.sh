#!/bin/bash

export NDK=/Users/sunsheng/Library/Android/sdk/ndk/24.0.8215888

export ZLIB=zlib-1.2.12
export PCRE=pcre-8.44
export OPENSSL=openssl-1.1.1i
export LIGHTTPD=lighttpd-1.4.58

#############################################################
# download
#############################################################

mkdir -p src
cd src
wget -nc https://zlib.net/$ZLIB.tar.xz
wget -nc https://onboardcloud.dl.sourceforge.net/project/pcre/pcre/8.44/pcre-8.44.tar.gz
# wget -nc https://ftp.pcre.org/pub/pcre/$PCRE.tar.gz
wget -nc https://www.openssl.org/source/$OPENSSL.tar.gz
wget -nc https://download.lighttpd.net/lighttpd/releases-1.4.x/$LIGHTTPD.tar.xz

if [ ! -d ./$ZLIB ]; then
tar xvf $ZLIB.tar.xz
fi

if [ ! -d ./$PCRE ]; then
tar xvf $PCRE.tar.gz
fi

if [ ! -d ./$OPENSSL ]; then
tar xvf $OPENSSL.tar.gz
fi

if [ ! -d ./$LIGHTTPD ]; then
tar xvf $LIGHTTPD.tar.xz
fi
cd ..

##############################################################

export TARGET=i686-linux-android
export API=26
export BLD=`pwd`
export ANDROID_NDK_HOME=$NDK
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64


export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++

export AR=$TOOLCHAIN/bin/llvm-ar
export AS=$TOOLCHAIN/bin/llvm-as
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip


if [ ! -d $NDK ]; then
echo "Please configure NDK"
exit
fi

set -e
# rm -rf include bin dist lib sbin share

if [ ! -f "$BLD/include/zlib.h" ]; then
cd $BLD/src/$ZLIB
./configure --prefix=$BLD --static
make install
fi

if [ ! -f "$BLD/include/pcre.h" ]; then
cd $BLD/src/$PCRE
./configure --host=$TARGET --prefix=$BLD --disable-shared
make install
fi




echo BUILDING LIGHTTPD
cd $BLD/src/$LIGHTTPD
if [ -f "Makefile" ]; then
make distclean
fi
rm -f src/plugin-static.h 
cp $BLD/plugin-static.h ./src/
CPPFLAGS=-DLIGHTTPD_STATIC LIGHTTPD_STATIC=yes ./configure -C --host=$TARGET --enable-static=yes --enable-shared=no --disable-shared --prefix=$BLD --disable-ipv6 --with-pcre=$BLD --with-zlib=$BLD
sed -i.bak '/lighttpd-mod_webdav/d' ./src/Makefile
make install-strip


