FROM ubuntu:18.04 as build
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Warsaw
RUN apt-get -y update
RUN apt-get -y install git make
RUN apt-get -y install g++
RUN cp /etc/apt/sources.list /etc/apt/sources.list~ && sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && apt-get update
RUN apt-get -y build-dep qt5-default
RUN apt-get -y install libxcb-xinerama0-dev build-essential perl python git "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev flex bison gperf libicu-dev libxslt-dev ruby libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libfontconfig1-dev libcap-dev libxtst-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libxss-dev libegl1-mesa-dev gperf bison libbz2-dev libgcrypt20-dev libdrm-dev libcups2-dev libatkmm-1.6-dev libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libbluetooth-dev bluetooth blueman bluez libusb-dev libdbus-1-dev bluez-hcidump bluez-tools libbluetooth-dev libgles2-mesa-dev
RUN cd /opt &&\
    mkdir qt5 &&\
    git clone https://code.qt.io/qt/qt5.git &&\
    cd /opt/qt5 &&\
    git checkout 5.12 &&\
    perl init-repository --module-subset=default,-qtwebkit,-qtwebkit-examples,-qtwebengine &&\
    mkdir build &&\
    cd build &&\
    ../configure -prefix /opt/Qt/5.12-static/ -release -opensource -confirm-license -static -no-sql-mysql -no-sql-psql -no-sql-sqlite -no-journald -qt-zlib -no-mtdev -no-gif -qt-libpng -qt-libjpeg -qt-harfbuzz -qt-pcre -qt-xcb -no-glib -no-compile-examples -no-cups -no-iconv -no-tslib -dbus-linked -no-xcb-xlib -no-eglfs -no-directfb -no-linuxfb -no-kms -nomake examples -nomake tests -skip qtwebsockets -skip qtwebchannel -skip qtwebengine -skip qtwayland -skip qtwinextras -skip qtsensors -skip multimedia -no-evdev -no-libproxy -no-icu -qt-freetype -skip qtimageformats -opengl es2 &&\
    make -j9 &&\
    make install
WORKDIR /usr/local/app
COPY ./ /usr/local/app
RUN cd /usr/local/app &&\
    bash ./build_lin_free
FROM scratch as artifact
COPY --from=build /var/task/urs/local/app/build/lin/vesc_tool_free_linux.zip  /vesc_tool_free_linux.zip

# docker buildx build --target=artifact --output type=local,dest=. .
