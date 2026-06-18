##  Copyright (c) MediaArea.net SARL. All Rights Reserved.
##
##  Use of this source code is governed by a BSD-style license that can
##  be found in the License.html file in the root of the source tree.
##

$ErrorActionPreference = "Stop"

#-----------------------------------------------------------------------
# Setup
$release_directory = $PSScriptRoot
$version = (Get-Content "${release_directory}\..\Project\version.txt" -Raw).Trim()
$arch = "x64"

#-----------------------------------------------------------------------
# Cleanup
$artifact = "${release_directory}\mkvnote_ROOT"
if (Test-Path "${artifact}") {
    Remove-Item -Force -Recurse "${artifact}"
}

$artifact = "${release_directory}\mkvnote_BUILD"
if (Test-Path "${artifact}") {
    Remove-Item -Force -Recurse "${artifact}"
}

$artifact = "${release_directory}\MediaInfo.zip"
if (Test-Path "${artifact}") {
    Remove-Item -Force "${artifact}"
}

$artifact = "${release_directory}\mkvtoolnix.7z"
if (Test-Path "${artifact}") {
    Remove-Item -Force "${artifact}"
}

New-Item -Force -ItemType Directory "${release_directory}\mkvnote_ROOT\bin"

#-----------------------------------------------------------------------
# Get MediaInfo CLI
Push-Location -Path "${release_directory}/"
    $mi_index = curl.exe -L "https://mediaarea.net/download/binary/mediainfo/"
    $mi_version = ([regex]::Matches(${mi_index}, 'href="([0-9.]+)/"') | Select-Object -First 1).Groups[1].Value

    curl.exe -L "https://mediaarea.net/download/binary/mediainfo/${mi_version}/MediaInfo_CLI_${mi_version}_Windows_${arch}.zip" -o "MediaInfo.zip"
    7z.exe x -oMediaInfo "MediaInfo.zip"

    Copy-Item -Force -Path "${release_directory}/MediaInfo/MediaInfo.exe" -Destination "${release_directory}/mkvnote_ROOT/bin/mediainfo.exe"

    Remove-Item -Force -Recurse "${release_directory}/MediaInfo"
Pop-Location

#-----------------------------------------------------------------------
# Get MkvToolnix
Push-Location -Path "${release_directory}/"
    curl.exe -L "https://mkvtoolnix.download/windows/releases/99.0/mkvtoolnix-64-bit-99.0.7z" -o "mkvtoolnix.7z"
    7z.exe x "mkvtoolnix.7z"

    Copy-Item -Force -Path "${release_directory}/mkvtoolnix/mkvextract.exe" -Destination "${release_directory}/mkvnote_ROOT/bin/mkvextract.exe"
    Copy-Item -Force -Path "${release_directory}/mkvtoolnix/mkvinfo.exe" -Destination "${release_directory}/mkvnote_ROOT/bin/mkvinfo.exe"
    Copy-Item -Force -Path "${release_directory}/mkvtoolnix/mkvmerge.exe" -Destination "${release_directory}/mkvnote_ROOT/bin/mkvmerge.exe"
    Copy-Item -Force -Path "${release_directory}/mkvtoolnix/mkvpropedit.exe" -Destination "${release_directory}/mkvnote_ROOT/bin/mkvpropedit.exe"

    Remove-Item -Force -Recurse "${release_directory}/mkvtoolnix"
Pop-Location

#-----------------------------------------------------------------------
# Build mkvnote-qt
Push-Location -Path "${release_directory}/"
    New-Item -Force -ItemType Directory "mkvnote_BUILD"
    Push-Location -Path "mkvnote_BUILD"
        cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${release_directory}/mkvnote_ROOT/" ../..
        ninja install

        windeployqt --release --no-compiler-runtime --no-translations "${release_directory}/mkvnote_ROOT/bin/mkvnote-gui.exe"
    Pop-Location
Pop-Location

