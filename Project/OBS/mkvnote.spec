# Copyright (c) 2026 info@mediaarea.net
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.

# norootforbuild

Name:           mkvnote
Version:        1.0.0
Release:        1
Summary:        Qt GUI for editing MKV file metadata tags
Group:          Productivity/Multimedia/Other
License:        GPL-3.0-or-later
URL:            https://mediaarea.net
Source0:        mkvnote_%{version}.tar.xz
BuildRequires:  gcc
BuildRequires:  cmake
%if 0%{?suse_version}
BuildRequires:  ninja
%else
BuildRequires:  ninja-build
%endif

%if 0%{?fedora_version} ||  0%{?rhel}
BuildRequires:  pkgconfig(Qt6)
%endif

%if 0%{?mageia}
BuildRequires:  lib64qt6base6-devel
%endif

%if 0%{?suse_version}
BuildRequires:  pkgconfig(Qt6Core)
BuildRequires:  pkgconfig(Qt6Xml)
BuildRequires:  pkgconfig(Qt6Widgets)
%endif

%description
GUI tool for editing MKV file metadata tags according to NMAAHC archival
standards. Provides a Qt GUI (mkvnote-gui) for viewing and modifying tags
embedded in Matroska video files.

mkvnote accepts either a <mkv_file> or <csv_file> as an input. If an mkv file
is used then a data entry GUI window will open. If a csv is used, the mkvnote
will embed the metadata of the csv into the associated mkv files. Note that
with a csv input the first column must be 'filename' and contain a path to
the associated mkv file.

Requires: mediainfo
Requires: mkvtoolnix

%prep
%setup -q -n mkvnote

%build
%if 0%{?suse_version} || 0%{?mageia}
cmake -S . -B build.dir -G Ninja \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DCMAKE_INSTALL_PREFIX=%{_prefix}
cmake --build build.dir -- %{?_smp_mflags}
%else
%cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
%cmake_build
%endif

%install
%if 0%{?suse_version} || 0%{?mageia}
DESTDIR=%{buildroot} cmake --install build.dir
%else
%cmake_install
%endif

%files
%defattr(-,root,root,-)
%license LICENSE
%doc README.md
%{_bindir}/mkvnote
%{_bindir}/mkvnote-gui

%changelog
