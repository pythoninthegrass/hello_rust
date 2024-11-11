# syntax=docker/dockerfile:1.7.0

FROM --platform=$BUILDPLATFORM rust:alpine3.20 AS chef

WORKDIR /app

ENV PKG_CONFIG_SYSROOT_DIR=/
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
ENV CARGO_INCREMENTAL=0
ENV CARGO_BUILD_JOBS=12
ENV RUSTFLAGS="-Awarnings -C target-feature=-crt-static -C link-arg=-fuse-ld=mold -C link-arg=-s"

RUN apk add --no-cache \
    bash \
    build-base \
    clang \
    g++ \
    git \
    mold \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    perl \
    zig

RUN cargo install --locked cargo-zigbuild cargo-chef
RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl

FROM chef AS planner

COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

# https://doc.rust-lang.org/cargo/reference/profiles.html
# 4 built-in profiles: dev, release, test, and bench
ARG PROFILE=${PROFILE:-dev}
ARG APP_NAME=hello_rust
ARG CARGO_TARGET_DIR=/app/target/${PROFILE}

# Cook dependencies for all targets
RUN cargo chef cook --recipe-path recipe.json --profile ${PROFILE} --zigbuild \
    --target x86_64-unknown-linux-musl \
    --target aarch64-unknown-linux-musl

COPY . .

# Build for all targets using zigbuild
RUN <<EOF
#!/usr/bin/env bash
cargo zigbuild --profile ${PROFILE} \
    --target x86_64-unknown-linux-musl \
    --target aarch64-unknown-linux-musl

mkdir -p /app/linux
if [ "${PROFILE}" = "dev" ]; then
    cp ${CARGO_TARGET_DIR}/x86_64-unknown-linux-musl/debug/${APP_NAME} /app/linux/amd64
    cp ${CARGO_TARGET_DIR}/aarch64-unknown-linux-musl/debug/${APP_NAME} /app/linux/arm64
elif [ "${PROFILE}" = "release" ]; then
    cp ${CARGO_TARGET_DIR}/x86_64-unknown-linux-musl/release/${APP_NAME} /app/linux/amd64
    cp ${CARGO_TARGET_DIR}/aarch64-unknown-linux-musl/release/${APP_NAME} /app/linux/arm64
else
    echo "Unknown profile: ${PROFILE}"
    exit 1
fi
EOF

FROM alpine:3.20 AS runtime

WORKDIR /app

ARG TARGETPLATFORM
COPY --from=builder /app/linux/${TARGETPLATFORM#linux/} /app/hello_rust
COPY --from=builder /app/src/static /app/static

ARG ROCKET_PORT=8000
ENV ROCKET_PORT=${ROCKET_PORT}
EXPOSE ${ROCKET_PORT}

CMD ["/app/hello_rust"]
