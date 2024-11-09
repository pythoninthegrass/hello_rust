VERSION 0.8
IMPORT github.com/earthly/lib/rust:3.0.1 AS rust
FROM rust:slim-bookworm
WORKDIR /app

ARG --global APP_NAME="hello_rust"
ARG --global REGISTRY="ghcr.io"
ARG --global ORGANIZATION="pythoninthegrass"
ARG --global REPOSITORY="hello_rust"

install:
    FROM rust:1.82.0-bookworm
    RUN apt-get update -qq
    RUN apt-get install --no-install-recommends -qq \
        autoconf autotools-dev libtool-bin clang cmake bsdmainutils
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
    FROM debian:bookworm-slim
    WORKDIR /app
    COPY +build/$APP_NAME $APP_NAME
    COPY +source/static static
    ENV ROCKET_PORT=8000
    EXPOSE $ROCKET_PORT
    ENTRYPOINT ./$APP_NAME
    ARG TAG="latest"
    SAVE IMAGE --push "${REGISTRY}/${ORGANIZATION}/${REPOSITORY}:${TAG}"
