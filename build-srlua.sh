#!/usr/bin/env bash

# Build Script for sokol and other libs to be run by CI on github or gitlab
#    Notes: 
#         I see no value in makefiles and cmake when the below will work just fine. 
#         This is more maintainable, more platform friendly and much less work to config.
#         If I were building thousands of files or similar, I would use lua-make. 

PLATFORM=$1

# Default compiler and linker settings
BASE_INCLUDE="-I./ -I/usr/include -I/usr/local/include -I./src -I./LuaJIT-2.1/src"
BASE_INLCUDE_LIB="-L/usr/local/include -L/usr/include "

COMPILE_FLAGS="-lpthread -lm"

DEFS=

echo "Building for platform ${PLATFORM}"

# Source files. Add to list as needed. If this gets to big. Break up into multiple lists. Simple.
tgt01=("srlua" "srlua" "-fpic" "")
tgt02=("glue" "glue" "-fpic" "")

TARGET_FILES=(tgt01[@] tgt02[@])

# Simple build loops. 
# ----------------------------- BUILD LINUX ---------------------------------
if [ "${PLATFORM}" = "linux" ]; then
echo "Linux."
echo "Luajit Build"
cd LuaJIT-2.1/src
make
cp luajit ../../bin/linux
cp libluajit.so ../../bin/linux
cd ../..

echo srlua Build
COMPILE_FLAGS="$COMPILE_FLAGS -lX11 -lXi -lXcursor -lGL -lpthread -lasound"

COUNT=${#TARGET_FILES[@]}
for ((i=0; i<$COUNT; i++))
do
    declare -a tgt=(${!TARGET_FILES[i]})
    gcc ${BASE_INCLUDE} ${tgt[2]} ${DEFS} src/${tgt[0]}.c -o ./bin/linux/${tgt[1]} ${COMPILE_FLAGS} -L ./bin/linux -lluajit
done

# ----------------------------- BUILD MACOS ---------------------------------
elif [ "${PLATFORM}" = "macosx" ]; then
echo "MacOS."
echo "Luajit Build"
cd LuaJIT-2.1/src
make MACOSX_DEPLOYMENT_TARGET=10.14
cp luajit ../../bin/macos
cp libluajit.so ../../bin/macos
cd ../..

echo srlua Build
DEFS="-D__APPLE__"
COMPILE_FLAGS="-framework Cocoa -framework QuartzCore -framework AudioToolbox -framework OpenGL $COMPILE_FLAGS"

COUNT=${#TARGET_FILES[@]}
for ((i=0; i<$COUNT; i++))
do
    declare -a tgt=(${!TARGET_FILES[i]})
    g++ -xobjective-c++ ${BASE_INCLUDE} ${tgt[2]} ${DEFS} src/${tgt[0]}.c -o ./bin/macos/${tgt[1]} -L ./bin/macos -lluajit
done

# ----------------------------- BUILD MACOS ARM64 ---------------------------------
elif [ "${PLATFORM}" = "macos_arm64" ]; then
echo "MacOS Arm64"
echo "Luajit Build"
cd LuaJIT-2.1/src
make MACOSX_DEPLOYMENT_TARGET=10.14
cp luajit ../../bin/macos64
cp luajit.so ../../bin/macos64
cd ../..

echo srlua Build
DEFS="-D__APPLE__ -D__APPLE__"
COMPILE_FLAGS="-arch arm64 -framework Cocoa -framework QuartzCore -framework AudioToolbox -framework OpenGL $COMPILE_FLAGS"

COUNT=${#TARGET_FILES[@]}
for ((i=0; i<$COUNT; i++))
do
    declare -a tgt=(${!TARGET_FILES[i]})
    g++ -xobjective-c++ ${BASE_INCLUDE} ${tgt[2]} ${DEFS} src/${tgt[0]}.c -o ./bin/macos64/${tgt[1]} 
done

# # ----------------------------- BUILD IOS64 ---------------------------------
# elif [ "${PLATFORM}" = "ios64" ]; then
# echo "IOS64."
# DEFS="-DTARGET_OS_IPHONE -D__APPLE__ -DSOKOL_GLCORE"
# COMPILE_FLAGS="-framework Cocoa -framework QuartzCore -framework AudioToolbox -framework OpenGL $COMPILE_FLAGS"

# COUNT=${#TARGET_FILES[@]}
# for ((i=0; i<$COUNT; i++))
# do
#     declare -a tgt=(${!TARGET_FILES[i]})

#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${tgt[2]} ${DEFS} lib/${tgt[0]}.c -o ./bin/lib${tgt[1]}_ios64.o 
#     g++ -dynamiclib ${BASE_INLCUDE_LIB} -o ./bin/lib${tgt[1]}_ios64.so ./bin/lib${tgt[1]}_ios64.o ${REMOTERY} ${COMPILE_FLAGS}
# done

# ----------------------------- BUILD ANDROID ---------------------------------
elif [ "${PLATFORM}" = "android" ]; then
echo "Android."
fi

# ------------ OLD METHOD - deprecated ---------------------------
# if [ "${PLATFORM}" = "linux" ]; then
#     gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-dll.c -o ./bin/libsokol_dll.so ${COMPILE_FLAGS}
#     gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-debug-dll.c -o ./bin/libsokol_debug_dll.so ${COMPILE_FLAGS}
#     gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-shape-dll.c -o ./bin/libsokol_shape_dll.so ${COMPILE_FLAGS}
#     gcc -c -I./lib/nuklear ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-nuklear-dll.c -o ./bin/libsokol_nuklear_dll.so ${COMPILE_FLAGS}
#     # gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-imgui-dll.c -o ./bin/sokol_imgui_dll.so ${COMPILE_FLAGS}
#     gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/hmm-dll.c -o ./bin/libhmm_dll.so ${COMPILE_FLAGS}
#     gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} -DRMT_DLL lib/remotery/Remotery.c -o ./bin/libremotery_dll.so ${COMPILE_FLAGS}
#     gcc -c ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/stb-dll.c -o ./bin/libstb_dll.so ${COMPILE_FLAGS}
# elif [ "${PLATFORM}" = "macosx" ]; then
# DEFS="-DTARGET_OS_IPHONE -D__APPLE__ -DSOKOL_GLCORE"
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-dll.c -o ./bin/libsokol_dll_macos.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-debug-dll.c -o ./bin/libsokol_debug_dll_macos.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-shape-dll.c -o ./bin/libsokol_shape_dll_macos.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ -I./lib/nuklear -Wno-address-of-temporary ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-nuklear-dll.c -o ./bin/libsokol_nuklear_dll_macos.so ${COMPILE_FLAGS}
#     # g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-imgui-dll.c -o ./bin/libsokol_imgui_dll_macos.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/hmm-dll.c -o ./bin/libhmm_dll_macos.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} -DRMT_DLL lib/remotery/Remotery.c -o ./bin/libremotery_dll_macos.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/stb-dll.c -o ./bin/libstb_dll_macos.so ${COMPILE_FLAGS}
# elif [ "${PLATFORM}" = "ios64" ]; then
# DEFS="-D__APPLE__ -DSOKOL_GLCORE"
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-dll.c -o ./bin/libsokol_dll_ios64.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-debug-dll.c -o ./bin/libsokol_debug_dll_ios64.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-shape-dll.c -o ./bin/libsokol_shape_dll_ios64.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ -I./lib/nuklear ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-nuklear-dll.c -o ./bin/libsokol_nuklear_dll_ios64.so ${COMPILE_FLAGS}
#     # g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/sokol-imgui-dll.c -o ./bin/libsokol_imgui_dll_ios64.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/hmm-dll.c -o ./bin/libhmm_dll_ios64.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} -DRMT_DLL lib/remotery/Remotery.c -o ./bin/libremotery_dll_ios64.so ${COMPILE_FLAGS}
#     g++ -c -xobjective-c++ ${BASE_INCLUDE} ${BASE_INLCUDE_LIB} ${DEFS} lib/stb-dll.c -o ./bin/libstb_dll_ios64.so ${COMPILE_FLAGS}
# elif [ "${PLATFORM}" = "android" ]; then
#     export PATH="android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/:$PATH"
#     export PATH="android-ndk/toolchains/llvm/prebuilt/linux-x86_64/:$PATH"
    
#     aarch64-linux-android21-clang -c -I./ -D__ANDROID__ -DSOKOL_GLES3 -Iandroid-ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include lib/sokol-dll.c -o ./bin/sokol_dll_aarch64.so -D__ANDROID__ -D__ANDROID_MIN_SDK_VERSION__=21 -lpthread -lm -fPIC -static
#     rm sokol-dll.o
#     armv7a-linux-androideabi19-clang -c -I./ -D__ANDROID__ -DSOKOL_GLES3 -Iandroid-ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include lib/sokol-dll.c -o ./bin/sokol_dll_armv7.so -D__ANDROID__ -D__ANDROID_MIN_SDK_VERSION__=19 -lpthread -lm -fPIC -static
# fi

