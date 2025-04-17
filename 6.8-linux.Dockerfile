# Docker container to build Qt 6.8 for Linux 64-bit projects with latest cmake and linuxdeployqt
# Image: dobord/docker-qt:6.8-linux

FROM ubuntu:20.04

ARG CMAKE_VERSION=3.30.4
ARG QT_VERSION=6.8.3
ARG QT_LINUX_INSTALL_BASE="/opt/qt"
ARG QT_CONFIGURE_OPTIONS=" \
    -openssl-linked \
    -skip qtopcua \
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

WORKDIR /root
RUN --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  apt update \
&&  apt full-upgrade -y \
&&  apt install -y --no-install-recommends curl ca-certificates software-properties-common xz-utils locales \
&&  locale \
&&  locale -a \
&&  localectl || true \
&&  locale-gen en_US.UTF-8 \
&&  localectl set-locale LANG=en_US.UTF-8 \
&&  locale \
&&  locale -a \
&&  localectl || true \
&&  dpkg-reconfigure locales \
&&  locale \
&&  locale -a \
&&  localectl || true

WORKDIR /qt/src
RUN --mount=type=cache,target=/qt/src,sharing=locked \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  if ! [ -e "qt-everywhere-src-${QT_VERSION}.tar.xz" ] ; then \
        curl --http1.1 --location -O https://download.qt.io/archive/qt/$(echo "${QT_VERSION}" | cut -d. -f 1-2)/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz ; \
    else \
        echo "use cache for qt-everywhere-src-${QT_VERSION}.tar.xz" ; \
    fi ; \
    ls -lah

WORKDIR /cmake/src
RUN --mount=type=cache,target=/cmake/src,sharing=locked \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  if ! [ -e "install-cmake.sh" ] ; then \
        curl -Lo install-cmake.sh https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh ; \
    else \
        echo "use cache for install-cmake.sh" ; \
    fi ; \
    chmod +x install-cmake.sh \
&&  ls -lah

WORKDIR /cmake/src
RUN --mount=type=cache,target=/cmake/src,ro \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  ./install-cmake.sh --skip-license --prefix=/usr/local

WORKDIR /root
RUN --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
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
    zlib1g-dev

WORKDIR /root
RUN --mount=type=cache,target=/qt/src,ro \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  tar -xJf "/qt/src/qt-everywhere-src-${QT_VERSION}.tar.xz"

WORKDIR /root
RUN --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  cd qt-everywhere-src-* \
&&  ./configure -prefix "${QT_LINUX_INSTALL_BASE}/${QT_VERSION}/gcc_64" ${QT_CONFIGURE_OPTIONS} ${QT_CONFIGURE_EXTRA_OPTIONS} \
&&  cmake --build . --parallel \
&&  apt autoremove -y --purge \
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
&&  cmake --install . \
&&  ldconfig -v \
&&  cd .. \
&&  rm -rf qt-everywhere-src-* \
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
&&  curl -Lo linuxdeployqt.AppImage "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" \
&&  chmod a+x linuxdeployqt.AppImage \
&&  mv -v linuxdeployqt.AppImage /usr/local/bin/linuxdeployqt \
&&  groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user \
&&  echo -e "-nexport PATH=${QT_LINUX_PATH}/bin:${PATH} -n \
      export QT_LINUX_PATH=\"${QT_LINUX_INSTALL_BASE}/${QT_VERSION}/gcc_64\" -n \
      export QT_HOST_PATH=\"${QT_LINUX_PATH}\" -n \
      export QT_VERSION=\"${QT_VERSION}\" -n \
      " >>/home/user/.bashrc \
&&  chown user:user /home/user/.bashrc

USER user
WORKDIR /home/user
ENV HOME=/home/user
