#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    glu        \
    libdecor   \
    physfs     \
    python     \
    scons      \
    sdl2       \
    sdl2_image \
    sdl2_mixer

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package

# If the application needs to be manually built that has to be done down here
echo "Making nightly build of D2X-Rebirth..."
echo "---------------------------------------------------------------"
REPO="https://github.com/dxx-rebirth/dxx-rebirth"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone "$REPO" ./dxx-rebirth
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./dxx-rebirth
wget https://www.dxx-rebirth.com/d2x-rebirth_addons.zip
bsdtar -xvf d2x-rebirth_addons.zip

declare -a _common_opts=(
        "${MAKEFLAGS:-}"
        '-Cdxx-rebirth'
        'builddir=./build'
        'opengl=yes'
        'sdl2=yes'
        'sdlmixer=yes'
        'ipv6=yes'
        'use_udp=yes'
        'use_tracker=yes'
        'screenshot=png')
scons "${_common_opts[@]}" 'd1x=0' 'd2x=1'

mv -v build/d2x-rebirth/d2x-rebirth ../AppDir/bin
mv -v 'd2x-rebirth addons'/d2xr-hires.dxa ../AppDir/bin
mv -v 'd2x-rebirth addons'/"d2xr-sc55-music.dxa" ../AppDir/bin
mv -v d2x-rebirth/d2x-rebirth.desktop ../AppDir
cp contrib/packaging/linux/descent2.svg ../AppDir/.DirIcon
mv -v contrib/packaging/linux/descent2.svg ../AppDir
