#!/usr/bin/env bash

basedir=$(pwd)

if [ -z "$1" -o -z "$2" ]; then
  echo "Usage: $0 <redot branch> <base distro>"
  echo
  echo "Example: $0 4.x f40"
  echo
  echo "redot branch:"
  echo "        Informational, tracks the Redot branch these containers are intended for."
  echo
  echo "base distro:"
  echo "        Informational, tracks the base Linux distro these containers are based on."
  echo
  echo "The resulting image version will be <redot branch>-<base distro>."
  exit 1
fi

redot_branch=$1
base_distro=$2
img_version=$redot_branch-$base_distro
files_root="$basedir/files"

if [ ! -z "$PS1" ]; then
  # Confirm settings
  echo "Docker image tag: ${img_version}"
  echo
  while true; do
    read -p "Is this correct? [y/n] " yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) exit 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
fi

mkdir -p logs

docker build -t redot-fedora:${img_version} -f base.Dockerfile . 2>&1 | tee logs/base.log

build_image() {
  docker build \
    --build-arg img_version=${img_version} \
    -t redot-"$1:${img_version}" \
    -f "$1".Dockerfile . \
    2>&1 | tee logs/"$1".log
}

build_image linux
build_image windows

XCODE_SDK=16.1
OSX_SDK=14.5
IOS_SDK=17.5
if [ ! -r "files/Xcode_${XCODE_SDK}.xip" ]; then
  echo
  echo "Error: 'files/Xcode_${XCODE_SDK}.xip' is required for Apple platforms, but was not found or couldn't be read."
  echo "It can be downloaded from https://developer.apple.com/download/more/ with a valid apple ID."
  exit 1
fi

echo "Building OSX and iOS SDK packages. This will take a while"
build_image xcode
docker run -it --rm \
  -v "${files_root}":/root/files \
  -e XCODE_SDKV="${XCODE_SDK}" \
  -e OSX_SDKV="${OSX_SDK}" \
  -e IOS_SDKV="${IOS_SDK}" \
  redot-xcode:${img_version} \
  2>&1 | tee logs/xcode_packer.log

build_image osx
build_image ios