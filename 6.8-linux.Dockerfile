# Docker container to build Qt 6.8 for Linux 64-bit projects with latest cmake and linuxdeployqt
# Image: a12e/docker-qt:6.8-linux

FROM ubuntu:20.04
MAINTAINER Aurélien Brooke <dev@abrooke.fr>

ARG CMAKE_VERSION=3.30.4
ARG QT_VERSION=6.8.3
ARG QT_CONFIGURE_OPTIONS=" \
    -openssl-linked \
    -skip qtopcua \
    -nomake examples \
    -skip qt3d \
    -skip qtquick3dphysics \
    -skip qtwebengine \
    -release \
    -- \
    -DFEATURE_accessibility=ON \
    -DFEATURE_cups=ON \
    -DFEATURE_dbus_linked=ON \
    -DFEATURE_directfb=OFF \
    -DFEATURE_doubleconversion=ON \
    -DFEATURE_fontconfig=ON \
    -DFEATURE_freetype=ON \
    -DFEATURE_glib=ON \
    -DFEATURE_gtk=ON \
    -DFEATURE_icu=ON \
    -DFEATURE_jpeg=ON \
    -DFEATURE_libproxy=ON \
    -DFEATURE_mimetype_database=OFF \
    -DFEATURE_pcre2=ON \
    -DFEATURE_png=ON \
    -DFEATURE_rpath=OFF \
    -DFEATURE_sql_mysql=ON \
    -DFEATURE_sql_odbc=ON \
    -DFEATURE_sql_psql=ON \
    -DFEATURE_sql_sqlite=ON \
    -DFEATURE_ssl=ON \
    -DFEATURE_system_jpeg=ON \
    -DFEATURE_system_pcre2=ON \
    -DFEATURE_system_png=ON \
    -DFEATURE_system_proxies=ON \
    -DFEATURE_system_sqlite=ON \
    -DFEATURE_system_zlib=ON \
"
ARG QT_CONFIGURE_EXTRA_OPTIONS=""

RUN set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  apt update \
&&  apt full-upgrade -y \
&&  apt install -y --no-install-recommends curl ca-certificates software-properties-common xz-utils \
&&  curl -Lo install-cmake.sh https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh \
&&  chmod +x install-cmake.sh \
&&  ./install-cmake.sh --skip-license --prefix=/usr/local \
&&  rm -fv install-cmake.sh \
&&  add-apt-repository ppa:ubuntu-toolchain-r/test \
&&  apt autoremove -y --purge software-properties-common \
&&  apt install -y --no-install-recommends \
    g++-13 \
    git openssh-client \
    locales sudo \
    fuse file \
&&  update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-13 130 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-13 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-13 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-13 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-13 \
    --slave /usr/bin/cpp cpp /usr/bin/cpp-13 \
&&  apt install -y --no-install-recommends \
    libasound2-dev \
    libatspi2.0-dev \
    libb2-dev \
    libcups2-dev \
    libdbus-1-dev \
    libdouble-conversion-dev \
    libdrm-dev \
    libfontconfig-dev \
    libfreetype6-dev \
    libgbm-dev \
    libgl-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libglib2.0-dev \
    libglu1-mesa-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgtk-3-dev \
    libharfbuzz-dev \
    libicu-dev \
    libinput-dev \
    libjpeg-dev \
    libkrb5-dev \
    liblttng-ust-dev \
    libmtdev-dev \
    libmysqlclient-dev \
    libpcre2-dev \
    libpng-dev \
    libpq-dev \
    libproxy-dev \
    libpulse-dev \
    libsctp-dev \
    libsdl2-dev \
    libsqlite3-dev \
    libssl-dev \
    libsystemd-dev \
    libts-dev \
    libudev-dev \
    libvulkan-dev \
    libwayland-dev \
    libwebp-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxcb-cursor-dev \
    libxcb-glx0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0-dev \
    libxcb-xinput-dev \
    libxcb-xkb-dev \
    libxcb1-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxrender-dev \
    libzstd-dev \
    ninja-build \
    pkg-config \
    unixodbc-dev \
    zlib1g-dev \
&&  curl --http1.1 --location --output - https://download.qt.io/archive/qt/$(echo "${QT_VERSION}" | cut -d. -f 1-2)/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz | tar xJ \
&&  cd qt-everywhere-src-* \
&&  ./configure -prefix /usr/local ${QT_CONFIGURE_OPTIONS} ${QT_CONFIGURE_EXTRA_OPTIONS} \
&&  cmake --build . --parallel \
&&  cmake --install . \
&&  ldconfig -v \
&&  cd .. \
&&  rm -rf qt-everywhere-src-* \
&&  curl -Lo linuxdeployqt.AppImage "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" \
&&  chmod a+x linuxdeployqt.AppImage \
&&  mv -v linuxdeployqt.AppImage /usr/local/bin/linuxdeployqt \
&&  apt-get -qq clean \
&&  locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
&&  groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME=/home/user
