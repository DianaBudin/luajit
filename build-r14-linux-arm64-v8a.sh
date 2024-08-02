#!/bin/sh
out_dir=android
out_dir_abs=$(pwd)/${out_dir}
if [ -d "${out_dir_abs}" ]; then
     echo "dir remove: ${out_dir_abs}"
     rm -rf ${out_dir_abs}
fi

if [ ! -d "${out_dir_abs}" ]; then
     echo "dir create: ${out_dir_abs}"
     mkdir -p ${out_dir_abs}
fi

tar_file=android.tar
rm -f ./${tar_file}

echo "build with r12-linux ..."
NDK=$(pwd)/android-ndk-r12b
NDKBIN=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin
NDKABI=21
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm64"
NDKCROSS=$NDKBIN/aarch64-linux-android-

buildArch()  {
     ARCH=${1}
     lib_file="src/libluajit.a"
     if [ -e "${lib_file}" ]; then 
          echo "file remove: ${lib_file}"
          rm -rf ${lib_file}
     fi

     echo "build arch ${ARCH}"
     NDKARCH="-march=${ARCH}"
     make clean
     make \
          HOST_CC="gcc -m64" \
          CROSS=$NDKCROSS \
          TARGET_FLAGS="$NDKF $NDKARCH"

          # TARGET_AR="$NDKBIN/llvm-ar rcus" \
          # TARGET_STRIP=$NDKBIN/llvm-strip \
          # STATIC_CC=$NDKCC \
          # DYNAMIC_CC="$NDKCC -fPIC" \
          # TARGET_LD=$NDKCC \
          # TARGET_SYS=Linux \
     if [ $? -ne 0 ]; then
          return 1
     fi
     arch_dir=${out_dir_abs}/${ARCH}
     if [ ! -d ${arch_dir} ]; then 
          mkdir -p ${arch_dir}
     fi

     if [ -e ${lib_file} ]; then 
          mv ${lib_file} ${arch_dir}
          echo "file move: ${lib_file} => ${arch_dir}"
          return 0
     fi
     return 2
}

# armeabi-v7a x86 armeabi arm64-v8a
for arch in armv8-a
do
     buildArch ${arch}
     if [ $? -ne 0 ]; then
          echo "build arch failed: ${arch}"
          break
     else
          echo "build arch success: ${arch}"
     fi
done


tar cvf ${tar_file} android







