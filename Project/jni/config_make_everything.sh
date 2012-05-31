#!/bin/bash

function die {
  echo "$1 failed" && exit 1
}

export ARM_ARCH="armv7-neon" #can be: armv5te, armv6, armv7,armv7-neon, see as configure_ffmpeg.sh
export ARM_VFP="vfp" #can be: vfp or null


./configure_x264.sh || die "X264 configure"
./make_x264.sh || die "X264 make"
./configure_ffmpeg.sh || die "FFMPEG configure"
./make_ffmpeg.sh || die "FFMPEG make"

#change Android.mk
if [[ $ARM_VFP=="vfp" ]]; then
	suffix=$ARM_ARCH-$ARM_VFP
else
	suffix=$ARM_ARCH
fi

sed -i "s,LOCAL_MODULE[[:space:]]*:=[[:space:]]*videokit.*,LOCAL_MODULE  := videokit-$suffix," Android.mk
sed -i "s,LOCAL_MODULE[[:space:]]*:=[[:space:]]*ffmpeg.*,LOCAL_MODULE  := ffmpeg-$suffix," Android.mk

ndk-build

