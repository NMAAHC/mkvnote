##  Copyright (c) MediaArea.net SARL. All Rights Reserved.
 #
 #  Use of this source code is governed by a BSD-style license that can
 #  be found in the License.html file in the root of the source tree.
 ##

#!/bin/bash

# This has the followind dependencies:
# - cmake
# - ninja
# - Qt6 static build (<QtPrefix>/lib/cmake must be in the CMAKE_MODULE_PATH environment variable and <QtPrefix>/bin must be in the PATH).

# This script uses the following environment variables:
# - MACOS_CODESIGN_IDENTITY: The subject and ID part of the Apple development certificate (optional).

set -e

#-----------------------------------------------------------------------
# Setup
release_directory="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
version="$(<"${release_directory}/../Project/version.txt")"

export MAKEOPTS=-j$(($(sysctl -n hw.logicalcpu)+1))

export CXXFLAGS="-mmacosx-version-min=11.0 -arch x86_64 -arch arm64 $CXXFLAGS"
export CFLAGS="-mmacosx-version-min=11.0 -arch x86_64 -arch arm64 $CFLAGS"
export LDFLAGS="-mmacosx-version-min=11.0 -arch x86_64 -arch arm64 $LDFLAGS"

#-----------------------------------------------------------------------
# Cleanup
rm -fr "${release_directory}/mediainfo_ROOT"
rm -f "${release_directory}/MediaInfo.dmg"
rm -f "${release_directory}/mediainfo.pkg"

rm -f "${release_directory}/MKVToolNix-99.0-1-universal.dmg"

rm -fr "${release_directory}/libxml2"
rm -fr "${release_directory}/libxslt"
rm -fr "${release_directory}/xmlstarlet"
rm -fr "${release_directory}/csvprintf"

rm -fr "${release_directory}/mkvnote_BUILD"
rm -fr "${release_directory}/mkvnote_ROOT"
rm -fr "${release_directory}/mkvnote.app"
rm -f "${release_directory}/mkvnote_${version}_Mac.dmg"

rm -f "${release_directory}/mkvnote.entitlements"
rm -f "${release_directory}/mkvnote.Info.plist"

mkdir -p "${release_directory}"/mkvnote_ROOT/usr/local/{bin,lib/mkvnote/{bin,app}}
mkdir -p "${release_directory}"/mkvnote_ROOT/Applications

#-----------------------------------------------------------------------
# Get MediaInfo CLI
pushd "${release_directory}/"
    mi_version=$(curl -Ls https://mediaarea.net/download/binary/mediainfo | grep -Eo 'href="[0-9.]+/"' | head -n1 | grep -Eo '[0-9.]+')
    curl -L "https://mediaarea.net/download/binary/mediainfo/${mi_version}/MediaInfo_CLI_${mi_version}_Mac.dmg" -o MediaInfo.dmg

    hdiutil attach -noverify MediaInfo.dmg
    cp "/Volumes/MediaInfo/mediainfo.pkg" .
    hdiutil detach "/Volumes/MediaInfo"

    pkgutil --expand-full mediainfo.pkg mediainfo_ROOT
    cp -a mediainfo_ROOT/Payload/usr/local/bin/mediainfo mkvnote_ROOT/usr/local/lib/mkvnote/bin
popd

#-----------------------------------------------------------------------
# Get MKVToolNix
pushd "${release_directory}/"
    curl -L https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-universal.dmg -o MKVToolNix-99.0-1-universal.dmg

    hdiutil attach -noverify MKVToolNix-99.0-1-universal.dmg
    cp -a "/Volumes/MKVToolNix-99.0-1-universal/MKVToolNix.app" mkvnote_ROOT/usr/local/lib/mkvnote/app
    ln -s ../app/MKVToolNix.app/Contents/MacOS/mkvextract mkvnote_ROOT/usr/local/lib/mkvnote/bin/mkvextract
    ln -s ../app/MKVToolNix.app/Contents/MacOS/mkvinfo mkvnote_ROOT/usr/local/lib/mkvnote/bin/mkvinfo
    ln -s ../app/MKVToolNix.app/Contents/MacOS/mkvmerge mkvnote_ROOT/usr/local/lib/mkvnote/bin/mkvmerge
    ln -s ../app/MKVToolNix.app/Contents/MacOS/mkvpropedit mkvnote_ROOT/usr/local/lib/mkvnote/bin/mkvpropedit
    hdiutil detach "/Volumes/MKVToolNix-99.0-1-universal"
popd

#-----------------------------------------------------------------------
# Build libxml2 and libxslt
pushd "${release_directory}/"
    mkdir libxml2 libxslt
    curl -LO https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.1.tar.xz
    tar -C libxml2 --strip-components 1 -xvf libxml2-2.15.1.tar.xz
    curl -LO https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.43.tar.xz
    tar -C libxslt --strip-components 1 -xvf libxslt-1.1.43.tar.xz
    pushd libxml2
        ./configure --without-python --without-modules --without-iconv --without-icu --without-iso8859x --without-mem_debug --without-run_debug --with-regexps --with-tree --with-writer --with-pattern --with-push --with-valid --with-sax1 --with-legacy --enable-static --disable-shared
        make
    popd

    pushd libxslt
        ./configure --with-libxml-src="${release_directory}/libxml2" --without-python --without-modules --without-crypto --enable-static --disable-shared
        make
    popd

    cp -a libxslt/xsltproc/xsltproc mkvnote_ROOT/usr/local/lib/mkvnote/bin
popd

#-----------------------------------------------------------------------
# Build csvprintf
pushd "${release_directory}/"
    mkdir csvprintf
    curl -L "https://github.com/archiecobbs/csvprintf/archive/refs/tags/1.3.4.tar.gz" -o csvprintf-1.3.4.tar.gz
    tar -C csvprintf --strip-components 1 -xzf csvprintf-1.3.4.tar.gz

    pushd csvprintf
        ./autogen.sh
        PATH="${release_directory}/mkvnote_ROOT/usr/local/lib/mkvnote/bin:$PATH" ./configure
        make
    popd

    cp -a csvprintf/csvprintf mkvnote_ROOT/usr/local/lib/mkvnote/bin/
    cp -a csvprintf/xml2csv mkvnote_ROOT/usr/local/lib/mkvnote/bin/
popd

#-----------------------------------------------------------------------
# Build xmlstarlet
pushd "${release_directory}/"
    mkdir xmlstarlet
    curl -LO https://sourceforge.net/projects/xmlstar/files/xmlstarlet/1.6.1/xmlstarlet-1.6.1.tar.gz
    tar -C xmlstarlet --strip-components 1 -xvf xmlstarlet-1.6.1.tar.gz
    pushd xmlstarlet
        # Apply Gentoo patch to fix build with libxml2 >= 2.14
        curl -L "https://raw.githubusercontent.com/gentoo/gentoo/refs/heads/master/app-text/xmlstarlet/files/xmlstarlet-1.6.1-libxml2-2.14.0-compile.patch" | patch -p1
        curl -L "https://raw.githubusercontent.com/gentoo/gentoo/refs/heads/master/app-text/xmlstarlet/files/xmlstarlet-1.6.1-libxml2-2.13-stdin.patch" | patch -p1
        curl -L "https://raw.githubusercontent.com/gentoo/gentoo/refs/heads/master/app-text/xmlstarlet/files/xmlstarlet-1.6.1-clang16.patch" | patch -p1
        curl -L "https://raw.githubusercontent.com/gentoo/gentoo/refs/heads/master/app-text/xmlstarlet/files/xmlstarlet-1.6.1-clang17.patch" | patch -p1
        ./configure --enable-static-libs --disable-build-docs --with-libxml-src="${release_directory}/libxml2" --with-libxslt-src="${release_directory}/libxslt"
        make || true # Build fails on docs despite --disable-build-docs, force the build to be marked as successful
    popd
    cp -a xmlstarlet/xml mkvnote_ROOT/usr/local/lib/mkvnote/bin/xmlstarlet
popd

#-----------------------------------------------------------------------
# Build mkvnote-qt
pushd "${release_directory}/"
    mkdir mkvnote_BUILD
    pushd mkvnote_BUILD
        cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_INSTALL_PREFIX="${release_directory}/mkvnote_ROOT/usr/local" ../..
        ninja install
    popd
popd

#-----------------------------------------------------------------------
# Assemble .app bundle
cat - > "${release_directory}/mkvnote.entitlements" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
</dict>
</plist>
EOF

cat - > "${release_directory}/mkvnote.Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>mkvnote</string>
    <key>CFBundleExecutable</key>
    <string>mkvnote-gui</string>
    <key>CFBundleIdentifier</key>
    <string>com.github.amiaopensource.mkvnote</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>mkvnote</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${version}</string>
    <key>CFBundleVersion</key>
    <string>${version}</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
</dict>
</plist>
EOF

pushd "${release_directory}/"
    app_contents="mkvnote.app/Contents"

    mkdir -p "${app_contents}/MacOS"
    mkdir -p "${app_contents}/Resources"

    mv mkvnote_ROOT/usr/local/bin/mkvnote-gui "${app_contents}/MacOS/mkvnote-gui"
    cp -a mkvnote.Info.plist "${app_contents}/Info.plist"
popd

#-----------------------------------------------------------------------
# Sign binaries and .app bundle
pushd "${release_directory}/"
    if [ -n "${MACOS_CODESIGN_IDENTITY}" ] ; then
        find "mkvnote_ROOT" -path "mkvnote_ROOT/usr/local/lib/mkvnote/app" -prune -o -type f -print0 | while IFS= read -r -d '' f ; do
            if file "${f}" | grep -q 'Mach-O.*\(executable\|dynamically linked shared library\|bundle\)' ; then
                codesign --force --options runtime --timestamp --entitlements mkvnote.entitlements --sign "Developer ID Application: ${MACOS_CODESIGN_IDENTITY}" "${f}"
            fi
        done

        codesign --force --options runtime --timestamp --entitlements mkvnote.entitlements --sign "Developer ID Application: ${MACOS_CODESIGN_IDENTITY}" "mkvnote.app"/Contents/MacOS/mkvnote-gui
        codesign --force --options runtime --timestamp --entitlements mkvnote.entitlements --sign "Developer ID Application: ${MACOS_CODESIGN_IDENTITY}" "mkvnote.app"
    fi
popd

#-----------------------------------------------------------------------
# Package .pkg
pushd "${release_directory}/"
    cp -a mkvnote.app mkvnote_ROOT/Applications
    pkgbuild --root mkvnote_ROOT --identifier "com.github.amiaopensource.mkvnote" --version "${version}" "mkvnote.unsigned.pkg"
popd

#-----------------------------------------------------------------------
# Sign .pkg
pushd "${release_directory}/"
    if [ -n "${MACOS_CODESIGN_IDENTITY}" ] ; then
        productsign --sign "Developer ID Installer: ${MACOS_CODESIGN_IDENTITY}" "mkvnote.unsigned.pkg" "mkvnote.pkg"
    else
        mv -f "mkvnote.unsigned.pkg" "mkvnote.pkg"
    fi
popd

#-----------------------------------------------------------------------
# Package .dmg
pushd "${release_directory}/"
    tmp_path="$(mktemp -d)"
    trap "rm -rf ${tmp_path}" EXIT

    tmp_files="tmp-mkvnote"
    tmp_dmg="tmp-mkvnote.dmg"

    mkdir -p "${tmp_path}/${tmp_files}"
    cp -a "mkvnote.pkg" "${tmp_path}/${tmp_files}/"

    hdiutil create "${tmp_path}/${tmp_dmg}" -ov -fs HFS+ -format UDRW -volname "mkvnote" -srcfolder "${tmp_path}/${tmp_files}"
    hdiutil attach -readwrite -noverify "${tmp_path}/${tmp_dmg}"

    sleep 1

    echo '
        tell application "Finder"
            tell disk "mkvnote"
                open
                set current view of container window to icon view
                set toolbar visible of container window to false
                set the bounds of container window to {400, 100, 950, 600}
                set viewOptions to the icon view options of container window
                set arrangement of viewOptions to not arranged
                set icon size of viewOptions to 72
                set position of item "mkvnote.pkg" of container window to {125, 175}
                close
            end tell
        end tell
    ' | osascript

    hdiutil detach "/Volumes/mkvnote"
    hdiutil convert "${tmp_path}/${tmp_dmg}" -format UDBZ -o "mkvnote_${version}_Mac.dmg"
popd

#-----------------------------------------------------------------------
# Sign .dmg
pushd "${release_directory}/"
    if [ -n "${MACOS_CODESIGN_IDENTITY}" ] ; then
        codesign --force --options runtime --timestamp --sign "Developer ID Application: ${MACOS_CODESIGN_IDENTITY}" --identifier "com.github.amiaopensource.mkvnote" "mkvnote_${version}_Mac.dmg"
    fi
popd
