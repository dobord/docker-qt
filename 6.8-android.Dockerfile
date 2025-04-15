# Docker container to build Qt 6.8 for Android projects with latest cmake
# Image: dobord/docker-qt:6.8-android

FROM ubuntu:24.04
MAINTAINER Mikhail Kashin <dobordx@yandex.ru>

ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_NDK_VERSION=26.1.10909125
ARG AQT_EXTRA_ARGS="--module qtshadertools qtmultimedia qtwebsockets"
ARG BUILD_TOOLS_VERSION=34.0.0
ARG CMAKE_VERSION=3.30.4
ARG EXTRA_PACKAGES="git openssh-client"
ARG OPENSSL_VERSION=3.0.14
ARG QT_ARCHS="arm64_v8a armv7" # in arm64_v8a armv7 x86 x86_64
ARG QT_VERSION=6.8.3
ARG QT_ANDRIOD_INSTALL_BASE="/opt/qt"
ARG QT_LINUX_INSTALL_BASE="/opt/qt"
ARG SDKMANAGER_EXTRA_ARGS=""

ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${ANDROID_NDK_VERSION} \
    QT_ANDROID_PATH="${QT_ANDRIOD_INSTALL_BASE}/${QT_VERSION}/android_arm64_v8a" \
    QT_HOST_PATH="${QT_ANDRIOD_INSTALL_BASE}/${QT_VERSION}/gcc_64" \
    QT_VERSION=${QT_VERSION}
ENV ANDROID_NDK_HOME=${ANDROID_NDK_ROOT} \
    PATH=/opt/android-sdk/cmdline-tools/latest/bin:${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:${QT_ANDROID_PATH}/bin:${PATH}

RUN set -xe \
&&  export DEBIAN_FRONTEND=noninteractive \
&&  BUILD_PACKAGES="python3-pip" \
&&  apt update \
&&  apt full-upgrade -y \
&&  apt install -y --no-install-recommends \
        ${BUILD_PACKAGES} \
        ${EXTRA_PACKAGES} \
        curl \
        ca-certificates \
        default-jdk-headless \
        libxkbcommon0 \
        libgl1 libegl1 \
        libfontconfig1 \
        libx11-6 \
        libfreetype6 \
        make \
        perl \
        software-properties-common \
        sudo \
        unzip \
        xz-utils \
&&  curl -Lo install-cmake.sh https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh \
&&  chmod +x install-cmake.sh \
&&  ./install-cmake.sh --skip-license --prefix=/usr/local \
&&  rm -fv install-cmake.sh \
&&  curl -Lo tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
&&  unzip tools.zip && rm tools.zip \
&&  mkdir -p /opt/android-sdk/cmdline-tools/ \
&&  mv -v cmdline-tools /opt/android-sdk/cmdline-tools/latest \
&&  yes | sdkmanager --licenses \
&&  sdkmanager --update \
&&  sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" "platform-tools" "build-tools;${BUILD_TOOLS_VERSION}" "ndk;${ANDROID_NDK_VERSION}" ${SDKMANAGER_EXTRA_ARGS} \
&&  pip install --break-system-packages aqtinstall \
&&  aqt install-qt linux desktop ${QT_VERSION} linux_gcc_64 --outputdir "${QT_LINUX_INSTALL_BASE}" --module qtshadertools \
&&  curl -Lo openssl.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
&&  for QT_ARCH in ${QT_ARCHS} ; do \
        aqt install-qt linux android ${QT_VERSION} android_${QT_ARCH} --outputdir "${QT_ANDRIOD_INSTALL_BASE}" ${AQT_EXTRA_ARGS} ; \
        case $QT_ARCH in \
            "arm64_v8a" ) OPENSSL_ARCH=arm64  ;; \
            "armv7"     ) OPENSSL_ARCH=arm    ;; \
            "x86"       ) OPENSSL_ARCH=x86    ;; \
            "x86_64"    ) OPENSSL_ARCH=x86_64 ;; \
        esac ; \
        tar xzf openssl.tar.gz ; \
        cd openssl-${OPENSSL_VERSION}/ ; \
        sed -i 's/sub shlibvariant        { $target{shlib_variant} || "" }/sub shlibvariant        { "_3" }/g' ./Configurations/platform/Unix.pm ; \
        ./Configure android-${OPENSSL_ARCH} shared zlib-dynamic -no-engine no-tests --prefix="${QT_ANDRIOD_INSTALL_BASE}/${QT_VERSION}/android_${QT_ARCH}" -D__ANDROID_API__=28 ; \
        make build_libs ; \
        make install_sw ; \
        cd ../ ; \
        rm -rf openssl-${OPENSSL_VERSION} ; \
    done \
&&  rm -fv openssl.tar.gz \
&&  pip cache purge \
&&  apt autoremove --purge -y ${BUILD_PACKAGES} \
&&  rm -rf /var/lib/apt/lists/* \
&&  groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME=/home/user
