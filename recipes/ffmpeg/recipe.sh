#!/bin/bash
# Recent change made ffmpeg not compatible with python-for-android yet.
# Only h264+aac build are working.

VERSION_ffmpeg=
URL_ffmpeg=https://github.com/tito/ffmpeg-android/zipball/master/ffmpeg-android.zip
DEPS_ffmpeg=(python sdl)
MD5_ffmpeg=
BUILD_ffmpeg=$BUILD_PATH/ffmpeg/ffmpeg-android
RECIPE_ffmpeg=$RECIPES_PATH/ffmpeg

function prebuild_ffmpeg() {
	cd $BUILD_ffmpeg
	if [ ! -d ffmpeg ]; then
		try ./extract.sh
	fi
}

function build_ffmpeg() {
	cd $BUILD_ffmpeg

	if [ -d "$BUILD_PATH/python-install/lib/python2.7/site-packages/ffmpeg" ]; then
		return
	fi


	# build ffmpeg
	export NDK=$ANDROIDNDK
	if [ ! -f $BUILD_ffmpeg/build/ffmpeg/armeabi-v7a/lib/libavcodec.a ]; then
		try env FFMPEG_ARCHS='armv7a' ./build-h264-aac.sh
	fi

	push_arm

	# build python extension
	export JNI_PATH=$JNI_PATH
	export CFLAGS="$CFLAGS -I$JNI_PATH/sdl/include -I$JNI_PATH/sdl_mixer/"
	export LDFLAGS="$LDFLAGS -lm -L$LIBS_PATH"
	export FFMPEG_ROOT="$BUILD_ffmpeg/build/ffmpeg/armeabi-v7a"
	try cd $BUILD_ffmpeg/python
	try find . -iname '*.pyx' -exec cython {} \;
	try $BUILD_PATH/python-install/bin/python.host setup.py build_ext -v
	try $BUILD_PATH/python-install/bin/python.host setup.py install -O2

	pop_arm
}

function postbuild_ffmpeg() {
	true
}
