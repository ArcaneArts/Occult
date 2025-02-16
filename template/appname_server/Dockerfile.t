# Build the Server
FROM --platform=linux/amd64 dart:stable AS caremap-builder
ENV FLUTTER_HOME=/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

# Install tools required to run flutter & media libraries
RUN apt-get update && apt-get install -y \
    curl git unzip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Clone & Install Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    flutter channel stable && \
    flutter upgrade --force

# Build the project
WORKDIR /app
COPY pubspec.* ./
COPY subpackages ./subpackages
COPY . .
RUN flutter pub get
RUN flutter build linux --release

# Image Magick Capabilities
FROM --platform=linux/amd64 debian:bullseye-slim AS imagemagick-builder

# Install tools required to compile libraries for linux
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libltdl-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libjbig-dev \
    libgomp1 \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Compile ImageMackgic & Libraries
WORKDIR /tmp
RUN wget https://github.com/webmproject/libwebp/archive/refs/tags/v1.4.0.tar.gz \
    && tar xvzf v1.4.0.tar.gz \
    && cd libwebp-1.4.0 \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && wget https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-39.tar.gz \
    && tar xvzf 7.1.1-39.tar.gz \
    && cd ImageMagick-7.1.1-39 \
    && ./configure --disable-hdri --with-quantum-depth=8 --with-png=yes --with-webp=yes --with-jpeg=yes \
    --with-jp2=yes --without-tiff --with-modules --enable-shared \
    && make \
    && make install 

# Server Runtime
FROM --platform=linux/amd64 dart:stable
RUN apt-get update && apt-get install -y \
    wget \
    libltdl-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libjbig-dev \
    libgomp1 \
    xvfb \
    libgtk-3-0 \
    libegl1 \
    libgles2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Install built libraries into final image
COPY --from=imagemagick-builder /usr/local /usr/local
RUN ldconfig
WORKDIR /app
COPY --from=caremap-builder /app/build/linux/x64/release/bundle ./bundle
COPY --from=caremap-builder /app/ffi/libimage_magick_ffi.so ./bundle

# Link libraries to LD path so they are visible on linux
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/lib:

# Find the server executable
RUN find ./bundle -type f -executable ! -name "*.so" -printf "%f\n" > executable_name.txt
EXPOSE 8080

# Run the flutter server with xvfb to simulate a display
CMD xvfb-run -a ./bundle/$(cat executable_name.txt)