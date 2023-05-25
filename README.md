These Docker images allow you to very easily build a Qt app accross all platforms. You may use build system (e.g. Gitlab CI) to fully leverage these images.

Qt toolchain Docker images
==========================

Qt 6.3.2 (EOL 2023-04-12)
* `a12e/docker-qt:6.3-linux` (Ubuntu 18.04 LTS, GCC 11.1, CMake 3.24.2, linuxdeployqt)

Qt 6.4.3 (EOL 2023-09-29)
* `a12e/docker-qt:6.4-android` (Ubuntu 22.04 LTS, CMake 3.24.2, OpenSSL 1.1.1t)
* `a12e/docker-qt:6.4-linux` (Ubuntu 18.04 LTS, GCC 11.1, CMake 3.24.2, linuxdeployqt)

Qt 6.5.1
* `a12e/docker-qt:6.5-android` (Ubuntu 22.04 LTS, CMake 3.26.4, OpenSSL 1.1.1t)

Android example
---------------

```sh
docker run -it --rm --volume $PWD:/src a12e/docker-qt:6.5-android
```

```sh
mkdir ~/build && cd ~/build
qt-cmake /src -DQT_ANDROID_BUILD_ALL_ABIS=YES
cmake --build . --target aab
```

Linux example
-------------

```sh
docker run -it --rm --volume $PWD:/src a12e/docker-qt:6.4-linux
```

```sh
mkdir ~/build && cd ~/build
cmake /src
cmake --build . --parallel
cmake --install . --prefix $PWD/appdir/usr
linuxdeployqt appdir/usr/share/applications/*.desktop -qmldir=/src/resources/ -extra-plugins=platforms
cp -v /usr/lib/x86_64-linux-gnu/libstdc++.so.6 appdir/usr/lib/
linuxdeployqt appdir/usr/share/applications/*.desktop -appimage
```

Notes
-----

OpenSSL for Android is compiled and installed directly inside the Qt directory, so you can easily link to or ship it:
```cmake
find_package(OpenSSL 1.1 REQUIRED)
get_filename_component(OPENSSL_LIB_DIR ${OPENSSL_SSL_LIBRARY} DIRECTORY)
# To make androiddeployqt deploy OpenSSL (mandatory)
set_property(TARGET MyTarget
    APPEND PROPERTY QT_ANDROID_EXTRA_LIBS
    ${OPENSSL_LIB_DIR}/libcrypto_1_1.so
    ${OPENSSL_LIB_DIR}/libssl_1_1.so
)
# To use crypto in your app (optional)
target_link_libraries(MyTarget PRIVATE
    OpenSSL::Crypto
)
```

Linux images are built inside a 18.04 LTS Ubuntu, to allow the AppImage to be run on older systems. Otherwise, links to too recent versions of GLIBC are made. However, the `libstdc++.so.6` needs to be deployed, because Qt requires C++17 features.
