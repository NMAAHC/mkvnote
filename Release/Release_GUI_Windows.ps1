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
$artifact = "${release_directory}\mkvnote_GUI_${version}_Windows_${arch}"
if (Test-Path "${artifact}") {
    Remove-Item -Force -Recurse "${artifact}"
}

$artifact = "${release_directory}\mkvnote_GUI_${version}_Windows_${arch}.zip"
if (Test-Path "${artifact}") {
    Remove-Item -Force "${artifact}"
}

$artifact = "${release_directory}\mkvnote_GUI_${version}_Windows_${arch}.exe"
if (Test-Path "${artifact}") {
    Remove-Item -Force "${artifact}"
}

#-----------------------------------------------------------------------
# Package GUI
Push-Location "${release_directory}"
    New-Item -Force -ItemType Directory -Path "mkvnote_GUI_${version}_Windows_${arch}"
    Push-Location "mkvnote_GUI_${version}_Windows_${arch}"
        ### Copying: Exe ###
        Copy-Item -Force -Recurse ..\mkvnote_ROOT\bin\* .
        ### Archive
        7za.exe a -r -tzip -mx9 "..\mkvnote_GUI_${version}_Windows_${arch}.zip" *
    Pop-Location
Pop-Location

#-----------------------------------------------------------------------
# Package installer
Push-Location -Path "${release_directory}\..\Project\Install"
    makensis.exe mkvnote.nsi
Pop-Location