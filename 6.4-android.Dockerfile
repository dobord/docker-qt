# Docker container to build Qt 6.4 for Android projects with latest cmake
# Image: a12e/docker-qt:6.4-android

FROM ubuntu:22.04
MAINTAINER Aurélien Brooke <dev@abrooke.fr>

ARG ANDROID_NDK_VERSION=23.1.7779620
ARG AQT_EXTRA_ARGS="--module qt3d qtshadertools qtmultimedia"
ARG CMAKE_VERSION=3.24.2
ARG EXTRA_PACKAGES="git openssh-client"
ARG OPENSSL_VERSION=1.1.1t
ARG QT_VERSION=6.4.3
ARG SDKMANAGER_EXTRA_ARGS=""

ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${ANDROID_NDK_VERSION} \
    QT_ANDROID_PATH=/opt/qt/${QT_VERSION}/android_arm64_v8a \
    QT_HOST_PATH=/opt/qt/${QT_VERSION}/gcc_64 \
    QT_VERSION=${QT_VERSION}
ENV ANDROID_NDK_HOME=${ANDROID_NDK_ROOT} \
    PATH=/opt/android-sdk/cmdline-tools/latest/bin:${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:${QT_ANDROID_PATH}/bin:${PATH}

RUN set -xe \
&&  DEBIAN_FRONTEND=noninteractive \
&&  BUILD_PACKAGES="python3-pip" \
&&  apt update \
&&  apt full-upgrade -y \
&&  apt install -y --no-install-recommends \
        ${BUILD_PACKAGES} \
        ${EXTRA_PACKAGES} \
        curl \
        ca-certificates \
        default-jdk-headless \
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
&&  curl -Lo tools.zip https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip \
&&  unzip tools.zip && rm tools.zip \
&&  mkdir -p /opt/android-sdk/cmdline-tools/ \
&&  mv -v cmdline-tools /opt/android-sdk/cmdline-tools/latest \
&&  yes | sdkmanager --licenses \
&&  sdkmanager --update \
&&  sdkmanager "platforms;android-31" "platform-tools" "build-tools;31.0.0" "ndk;${ANDROID_NDK_VERSION}" ${SDKMANAGER_EXTRA_ARGS} \
&&  pip install aqtinstall \
&&  aqt install-qt linux desktop ${QT_VERSION} gcc_64 --outputdir /opt/qt \
&&  curl -Lo openssl.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
&&  for QT_ARCH in arm64_v8a armv7 x86 x86_64 ; do \
        aqt install-qt linux android ${QT_VERSION} android_${QT_ARCH} --outputdir /opt/qt ${AQT_EXTRA_ARGS} ; \
        ln -vs /opt/qt/${QT_VERSION}/gcc_64/libexec/qmlimportscanner /opt/qt/${QT_VERSION}/android_${QT_ARCH}/libexec/qmlimportscanner ; \
        case $QT_ARCH in \
            "arm64_v8a" ) OPENSSL_ARCH=arm64  ;; \
            "armv7"     ) OPENSSL_ARCH=arm    ;; \
            "x86"       ) OPENSSL_ARCH=x86    ;; \
            "x86_64"    ) OPENSSL_ARCH=x86_64 ;; \
        esac ; \
        tar xzf openssl.tar.gz ; \
        cd openssl-${OPENSSL_VERSION}/ ; \
        ./Configure android-${OPENSSL_ARCH} shared zlib-dynamic -no-engine no-tests --prefix=/opt/qt/${QT_VERSION}/android_${QT_ARCH} -D__ANDROID_API__=23 ; \
        make SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so build_libs ; \
        make SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so install_sw ; \
        cd ../ ; \
        rm -rf openssl-${OPENSSL_VERSION} ; \
    done \
&&  rm -fv openssl.tar.gz \
&&  pip uninstall -y aqtinstall \
&&  pip cache purge \
&&  apt autoremove --purge -y ${BUILD_PACKAGES} \
&&  rm -rf /var/lib/apt/lists/* \
&&  groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME=/home/user
