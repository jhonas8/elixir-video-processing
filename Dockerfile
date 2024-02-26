FROM elixir:1.11-alpine

ENV FFMPEG_VERSION=3.0.2
ENV WORKDIR /tmp/ffmpeg

RUN apk add --update build-base curl nasm tar bzip2 \
    zlib-dev openssl-dev yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev && \

    DIR=$(mktemp -d) && cd ${DIR} && \

    curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
    cd ffmpeg-${FFMPEG_VERSION} && \
    ./configure \
    --enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libass --enable-libwebp --enable-librtmp --enable-postproc --enable-avresample --enable-libfreetype --enable-openssl --disable-debug && \
    make && \
    make install && \
    make distclean && \

    rm -rf ${DIR} ß&& \
    apk del build-base curl tar bzip2 x264 openssl nasm && rm -rf /var/cache/apk/*

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install hex package manager
RUN mix local.hex --force

# Install rebar (Erlang build tool)
RUN mix local.rebar --force

# Compile the project
RUN mix do compile

# Make port 4000 available to the world outside this container
EXPOSE 4000

# Define environment variable
ENV MIX_ENV=prod

