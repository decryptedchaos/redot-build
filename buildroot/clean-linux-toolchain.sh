#!/bin/bash

set -e

if [ -z $1 ] || [ -z $2 ]; then
  echo "usage: $0 arch bits"
  exit 1
fi

arch=$1
bits=$2

bin_to_keep="aclocal autom4te autoconf autoheader automake autoreconf cmake gawk libtool m4 meson ninja pkgconf pkg-config python python3.11 scons tar toolchain-wrapper"
lib_to_keep="cmake gcc libpkgconf libpython3.11 libz libisl libmpc libmpfr libgmp libffi python3.11 pkgconfig libm libmvec"
share_to_keep="aclocal autoconf automake-1.16 autoconf-archive buildroot cmake gcc gettext-tiny libtool pkgconfig"
sysroot_share_to_keep="aclocal pkgconfig"

function clean_directory() {
  pushd $1
  files_to_keep="${@:2}"

  for file in $(ls -1); do
    keep_file=0
  
    if echo ${file} | grep -qe "^${arch}"; then
      keep_file=1
    fi
  
    for keep in ${files_to_keep}; do
      if echo ${file} | grep -qe "^${keep}"; then
        keep_file=1
        break
      fi
    done
  
    if [ ${keep_file} -eq 0 ]; then
      rm -rf ${file}
    fi
  done

  popd
}

rm -f $(find -name *.a | grep -vE '(nonshared|gcc|libstdc++)')
find -regex '.*\.so\(\..*\)?' -exec bin/${arch}-strip {} \; 2> /dev/null
find bin -exec bin/${arch}-strip {} \; 2> /dev/null
find ${arch}/bin -exec bin/${arch}-strip {} \; 2> /dev/null
find libexec/gcc -type f -exec bin/${arch}-strip {} \; 2> /dev/null

clean_directory bin ${bin_to_keep}
clean_directory lib ${lib_to_keep}
clean_directory share ${share_to_keep}
clean_directory ${arch}/sysroot/usr/share ${sysroot_share_to_keep}

find -name *.pyc -delete

rm -f usr lib64
rm -rf sbin var

for s in bin lib lib64 sbin; do
  if [ -L ${arch}/sysroot/${s} ]; then
    rm -f ${arch}/sysroot/${s}
  fi
done

if [ ${bits} == 64 ]; then
  libdir_to_remove=lib
  libdir_to_keep=lib64
else
  libdir_to_remove=lib64
  libdir_to_keep=lib
fi

rm -rf ${arch}/sysroot/usr/{bin,sbin}

mkdir -p ${arch}/sysroot/${libdir_to_keep}
cp ${arch}/sysroot/usr/${libdir_to_keep}/libpthread*so* ${arch}/sysroot/${libdir_to_keep}
cp ${arch}/sysroot/usr/${libdir_to_keep}/ld-linux*so* ${arch}/sysroot/${libdir_to_keep}
cp ${arch}/sysroot/usr/${libdir_to_keep}/libc*so* ${arch}/sysroot/${libdir_to_keep}
cp ${arch}/sysroot/usr/${libdir_to_keep}/libm.so* ${arch}/sysroot/${libdir_to_keep}
cp ${arch}/sysroot/usr/${libdir_to_keep}/libmvec.so* ${arch}/sysroot/${libdir_to_keep} || /bin/true # Does not exist on arm

if [ -L ${arch}/sysroot/usr/${libdir_to_keep} ]; then
  rm ${arch}/sysroot/usr/${libdir_to_keep}
  mv ${arch}/sysroot/usr/${libdir_to_remove} ${arch}/sysroot/usr/${libdir_to_keep}
  mkdir ${arch}/sysroot/usr/${libdir_to_remove}
  mv ${arch}/sysroot/usr/${libdir_to_keep}/crt*.o ${arch}/sysroot/usr/${libdir_to_remove}
  mv ${arch}/sysroot/usr/${libdir_to_keep}/pkgconfig ${arch}/sysroot/usr/${libdir_to_remove}
  # But why tho
  mv ${arch}/sysroot/usr/${libdir_to_keep}/pulseaudio ${arch}/sysroot/usr/${libdir_to_remove}
fi

mkdir -p ${arch}/sysroot/${libdir_to_remove}
cp ${arch}/sysroot/usr/${libdir_to_keep}/ld-linux*so* ${arch}/sysroot/${libdir_to_remove} # aarch64 apparently wants ld-linux.so in /lib not /lib64?

ln -s ${arch}-gcc bin/gcc
ln -s ${arch}-gcc.br_real bin/gcc.br_real
ln -s ${arch}-g++ bin/g++
ln -s ${arch}-g++.br_real bin/g++.br_real
ln -s ${arch}-cpp bin/cpp
ln -s ${arch}-cpp.br_real bin/cpp.br_real
ln -s ${arch}-ar bin/ar
ln -s ${arch}-ranlib bin/ranlib
ln -s ${arch}-gcc-ar bin/gcc-ar
ln -s ${arch}-gcc-ranlib bin/gcc-ranlib

find -name *python2* -exec rm -rf {} \; || true

