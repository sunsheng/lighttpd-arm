#!/bin/bash

export ZLIB=zlib-1.2.12
export PCRE=pcre-8.44
export OPENSSL=openssl-1.1.1q
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

# rm -rf ./$LIGHTTPD

if [ ! -d ./$LIGHTTPD ]; then
tar xvf $LIGHTTPD.tar.xz
fi
cd ..

##############################################################

export NDK=/Users/sunsheng/Library/Android/sdk/ndk/24.0.8215888
export TARGET=aarch64-linux-android
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

export PATH=$TOOLCHAIN/bin:$PATH

if [ ! -d $NDK ]; then
echo "Please configure NDK"
exit
fi

set -e

if [ ! -f "$BLD/include/zlib.h" ]; then
cd $BLD/src/$ZLIB
./configure --prefix=$BLD --static
make -j
make install
fi

if [ ! -f "$BLD/include/pcre.h" ]; then
cd $BLD/src/$PCRE
./configure --host=$TARGET --prefix=$BLD --disable-shared
make -j
make install
fi

if [ ! -f "$BLD/include/openssl/ssl.h" ] || [[ ! -f "$BLD/lib/libcrypto.a" ]] || [[ ! -f "$BLD/lib/libssl.a" ]]; then
echo BUILDING OPENSSL
cd $BLD/src/$OPENSSL
./Configure android-arm64 no-shared -D__ANDROID_API__=$API --prefix=$BLD
make -j
make install
fi


echo BUILDING LIGHTTPD
cd $BLD/src/$LIGHTTPD

cp $BLD/patch/* src/
./autogen.sh 

if [ -f "Makefile" ]; then
    make distclean
fi
rm -f src/plugin-static.h 
cp $BLD/patch/plugin-static.h ./src/
CPPFLAGS=-DLIGHTTPD_STATIC LIGHTTPD_STATIC=yes ./configure -C --host=$TARGET --enable-static=yes --enable-shared=no --disable-shared --prefix=$BLD --disable-ipv6 --with-pcre=$BLD --with-zlib=$BLD --with-openssl=$BLD
sed -i.bak '/lighttpd-mod_webdav/d' ./src/Makefile
sed -i.bak 's#-g -O2#-g#g' ./Makefile
sed -i.bak 's#-g -O2#-g#g' ./src/Makefile
make -j
make install



