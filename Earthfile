VERSION 0.8
IMPORT github.com/earthly/lib/rust:3.0.1 AS rust
FROM rust:alpine
WORKDIR /app

ARG --global APP_NAME="hello_rust"
ARG --global REGISTRY="ghcr.io"
ARG --global ORGANIZATION="pythoninthegrass"
ARG --global REPOSITORY="hello_rust"

install:
    FROM rust:1.82-alpine3.20
    RUN apk add --no-cache \
        autoconf \
        automake \
        clang \
        cmake \
        findutils \
        gcc \
        libtool \
        make \
        musl-dev \
        openssl-dev \
        pkgconfig
    RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl
    RUN rustup component add clippy
    RUN rustup component add rustfmt
    DO rust+INIT --keep_fingerprints=true

source:
    FROM +install
    COPY --keep-ts --dir src Cargo.toml Cargo.lock .
    SAVE ARTIFACT ./src/static static

build:
    FROM +source
    DO rust+CARGO \
        --args="build --release --bin ${APP_NAME}" \
        --output="release/[^/\.]+"
    SAVE ARTIFACT ./target/release/* $APP_NAME

docker:
    FROM alpine:3.20.3
    WORKDIR /app
    RUN apk add --no-cache \
        ca-certificates \
        libgcc
    COPY +build/$APP_NAME ./$APP_NAME
    COPY +source/static static
    ENV ROCKET_PORT=8000
    EXPOSE $ROCKET_PORT
    ENTRYPOINT ./$APP_NAME
    ARG TAG="latest"
    SAVE IMAGE --push "${REGISTRY}/${ORGANIZATION}/${REPOSITORY}:${TAG}"
