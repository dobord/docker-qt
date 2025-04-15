These Docker images allow you to very easily build a Qt app accross all platforms. You may use build system (e.g. Gitlab CI) to fully leverage these images.

Qt toolchain Docker images
==========================

Qt 6.3.2 (EOL 2023-04-12)
* `a12e/docker-qt:6.3-linux` (Ubuntu 18.04 LTS, GCC 11.1, CMake 3.24.2, linuxdeployqt)

Qt 6.4.3 (EOL 2023-09-29)
* `a12e/docker-qt:6.4-android` (Ubuntu 22.04 LTS, CMake 3.24.2, OpenSSL 1.1.1t)
* `a12e/docker-qt:6.4-linux` (Ubuntu 18.04 LTS, GCC 11.1, CMake 3.24.2, linuxdeployqt)

Qt 6.5.3 LTS
* `a12e/docker-qt:6.5-android` (Ubuntu 22.04 LTS, CMake 3.27.7, OpenSSL 3.0.11)
* `a12e/docker-qt:6.5-linux` (Ubuntu 20.04 LTS, GCC 11.1, CMake 3.27.7, linuxdeployqt)

Qt 6.7.3 (EOL 2024-10-02)
* `a12e/docker-qt:6.7-android` (Ubuntu 24.04 LTS, CMake 3.30.4, OpenSSL 3.0.14)
* `a12e/docker-qt:6.7-linux` (Ubuntu 20.04 LTS, GCC 13.1, CMake 3.30.4, linuxdeployqt)

Qt 6.8.3 LTS
* `dobord/docker-qt:6.8-android` (Ubuntu 24.04 LTS, CMake 3.30.4, OpenSSL 3.0.14)
* `dobord/docker-qt:6.8-linux` (Ubuntu 20.04 LTS, GCC 13.1, CMake 3.30.4, linuxdeployqt)
* `dobord/docker-qt:6.8-wasm` (Ubuntu 20.04 LTS, GCC 13.1, CMake 3.30.4, EMSDK 3.1.56, linuxdeployqt)

Android example
---------------

```sh
docker run -it --rm --volume $PWD:/src dobord/docker-qt:6.8-android
```

```sh
mkdir ~/build && cd ~/build
qt-cmake /src -DQT_ANDROID_BUILD_ALL_ABIS=YES
cmake --build . --target aab
```

Linux example
-------------

```sh
docker run -it --rm --volume $PWD:/src dobord/docker-qt:6.8-linux
```

```sh
mkdir ~/build && cd ~/build
cmake /src
cmake --build . --parallel
cmake --install . --prefix $PWD/appdir/usr
linuxdeployqt appdir/usr/share/applications/*.desktop -appimage -qmldir=/src/qml/ -extra-plugins=platforms
```

Notes
-----

OpenSSL for Android is compiled and installed directly inside the Qt directory, so you can easily link to or ship it:
```cmake
find_package(OpenSSL 1.1 REQUIRED)
get_filename_component(OPENSSL_LIB_DIR ${OPENSSL_SSL_LIBRARY} DIRECTORY)
# To make androiddeployqt deploy OpenSSL (mandatory)
# Use _1_1.so suffix instead of _3.so for OpenSSL 1.1 on Qt <= 6.4
set_property(TARGET MyTarget
    APPEND PROPERTY QT_ANDROID_EXTRA_LIBS
    ${OPENSSL_LIB_DIR}/libcrypto_3.so
    ${OPENSSL_LIB_DIR}/libssl_3.so
)
# To use crypto in your app (optional)
target_link_libraries(MyTarget PRIVATE
    OpenSSL::Crypto
)
```

Linux images are built inside a 20.04 LTS Ubuntu, to allow the AppImage to be run on older systems. Otherwise, links to too recent versions of the glibc are made.
