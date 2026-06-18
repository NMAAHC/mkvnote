##  Copyright (c) MediaArea.net SARL. All Rights Reserved.
 #
 #  Use of this source code is governed by a BSD-style license that can
 #  be found in the License.html file in the root of the source tree.
 ##

#!/bin/bash

set -e # fail on any error

if [ "${#}" -ne 1 ]; then
    echo "Usage: ${0} version"
    exit 1
fi

#-----------------------------------------------------------------------
# Setup
release_directory="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
version_new="${1}"
version_new_major="$(echo "${version_new}" | cut -d. -f1)"
version_new_minor="$(echo "${version_new}" | cut -d. -f2)"
version_new_build="$(echo "${version_new}" | cut -d. -f3)"
version_new_patch="$(echo "${version_new}" | cut -d. -f4)"
version_old="$(<"${release_directory}/../Project/version.txt")"

#-----------------------------------------------------------------------
# Processing versions with dots

files_dot=(
    "${release_directory}/../Project/version.txt"
    "${release_directory}/../Project/OBS/mkvnote.spec"
    "${release_directory}/../Project/OBS/mkvnote.dsc"
    "${release_directory}/../Project/OBS/PKGBUILD"
    "${release_directory}/../Project/Install/mkvnote.nsi"
    "${release_directory}/../mkvnote"
    "${release_directory}/../main.cpp"
    "${release_directory}/../mainwindow.cpp"
)

for file in "${files_dot[@]}"; do
   sed -i "s/${version_old//./\\.}/${version_new}/g" "${file}"
done

#-----------------------------------------------------------------------
# Processing nsi VERSION4
if [ -n "${version_new_patch}" ] ; then
    sed -i "s/!define PRODUCT_VERSION4 \"\${PRODUCT_VERSION}[0-9.]*\"/!define PRODUCT_VERSION4 \"\${PRODUCT_VERSION}\"/g" "${release_directory}/../Project/Install/mkvnote.nsi"
elif [ -n "${version_new_build}" ] ; then
    sed -i "s/!define PRODUCT_VERSION4 \"\${PRODUCT_VERSION}[0-9.]*\"/!define PRODUCT_VERSION4 \"\${PRODUCT_VERSION}.0\"/g" "${release_directory}/../Project/Install/mkvnote.nsi"
else
    sed -i "s/!define PRODUCT_VERSION4 \"\${PRODUCT_VERSION}[0-9.]*\"/!define PRODUCT_VERSION4 \"\${PRODUCT_VERSION}.0.0\"/g" "${release_directory}/../Project/Install/mkvnote.nsi"
fi

#-----------------------------------------------------------------------
# Update changelogs

date_rfc2822="$(LC_ALL=C date -u -R)"
debian_changelog="${release_directory}/../Project/OBS/debian.changelog"
cat - <<EOF > "${debian_changelog}.new"
mkvnote (${version_new}-1) stable; urgency=medium

  * Update to version ${version_new}

 -- MediaArea CI <info@mediaarea.net>  ${date_rfc2822}

EOF

sed -i "1e cat ${debian_changelog}.new" "${debian_changelog}"
rm -f "${debian_changelog}.new"

date_rpm="$(LC_ALL=C date -u '+%a %b %e %Y' | sed 's/  / /g')"
rpm_changelog="${release_directory}/../Project/OBS/mkvnote.changes"
cat - <<EOF > "${rpm_changelog}.new"
* ${date_rpm} MediaArea CI <info@mediaarea.net> - ${version_new}
- Version ${version_new}

EOF

sed -i "1e cat ${rpm_changelog}.new" "${rpm_changelog}"
rm -f "${rpm_changelog}.new"