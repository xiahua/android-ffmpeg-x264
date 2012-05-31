#!/bin/bash
pushd `dirname $0`
. settings.sh

if [[ $minimal_featureset == 1 ]]; then
  echo "Using minimal featureset"
  featureflags="--disable-everything \
--enable-decoder=mjpeg --enable-demuxer=mjpeg --enable-parser=mjpeg \
--enable-demuxer=image2 --enable-muxer=mp4 --enable-encoder=libx264 --enable-libx264 \
--enable-decoder=rawvideo \
--enable-protocol=file \
--enable-hwaccels"
fi

if [[ $DEBUG == 1 ]]; then
  echo "DEBUG = 1"
  DEBUG_FLAG="--disable-stripping"
fi

if [[ $ARM_ARCH == "armv5te" ]]; then
	target="--arch=arm5te \
		--enable-armv5te \
		--disable-neon "

elif [[ $ARM_ARCH == "armv6" ]]; then
	target="--arch=armv6 \
		--disable-neon "

elif [[ $ARM_ARCH == "armv7" ]]; then
	target="--arch=armv7 \
		--disable-neon "
else #armv7-neon
	target="--arch=armv7a \
		--cpu=cortex-a8 \
		--enable-neon"
fi

if [[ $ARM_VFP == "vfp" ]]; then
	target=$target" --enable-armvfp"
else
	target=$target" --disable-armvfp"
fi

echo "target: "$target

pushd ffmpeg

./configure $DEBUG_FLAG --enable-cross-compile \
$target \
--target-os=linux \
--disable-stripping \
--prefix=../output \
--enable-version3 \
--disable-shared \
--enable-static \
--enable-gpl \
--enable-memalign-hack \
--cc=arm-linux-androideabi-gcc \
--ld=arm-linux-androideabi-ld \
--extra-cflags="-fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated" \
$featureflags \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--enable-network \
--enable-filter=buffer \
--enable-filter=buffersink \
--disable-demuxer=v4l \
--disable-demuxer=v4l2 \
--disable-indev=v4l \
--disable-indev=v4l2 \
--extra-cflags="-I../x264 -Ivideokit" \
--extra-ldflags="-L../x264" 

popd; popd
