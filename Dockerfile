FROM alpine:latest AS build

ENV SRC=/usr/local
ENV PREFIX=/usr/local

RUN apk add --no-cache \
        alpine-sdk yasm nasm \
        git \
        fdk-aac-dev \
        fontconfig-dev \
        freetype-dev \
        fribidi-dev \
        lame-dev \
        libass-dev \
        libsrt-dev \
        libogg-dev \
        libpng-dev \
        libvorbis-dev \
        libvpx-dev \
        libwebp-dev \
        libxml2-dev \
        openjpeg-dev \
        opus-dev \
        openssl-dev \
        x264-dev \
        x265-dev

WORKDIR /tmp
COPY ffmpeg /tmp/ffmpeg
#RUN git clone https://github.com/hyww/ffmpeg
RUN    cd ffmpeg && \
    ./configure \
      --prefix="${PREFIX}" \
      --cpu=native \
      --disable-debug \
      --disable-doc \
      --disable-ffplay \
      --enable-fontconfig \
      --enable-libass \
      --enable-libfdk_aac \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libfribidi \
      --enable-libmp3lame \
      --enable-libopenjpeg \
      --enable-libopus \
      --enable-libsrt \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libwebp \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libxml2 \
      --enable-openssl \
      --enable-nonfree \
      --enable-version3 \
      --enable-gpl \
      --disable-shared && \
    make -j $(nproc) && \
    make install && \
    rm -rf /tmp/* /var/cache/apk/*

FROM alpine:latest AS runtime
ENV PREFIX=/usr/local

COPY --from=build ${PREFIX}/bin/ffmpeg ${PREFIX}/bin/
COPY --from=build ${PREFIX}/bin/ffprobe ${PREFIX}/bin/

RUN apk add --no-cache \
        ca-certificates \
        fdk-aac \
        fontconfig \
        freetype \
        fribidi \
        lame \
        libass \
        libsrt \
        libogg \
        libpng \
        libvorbis \
        libvpx \
        libwebp \
        libxml2 \
        openjpeg \
        opus \
        openssl \
        x264-libs \
        x265-libs

ENTRYPOINT ["ffmpeg"]