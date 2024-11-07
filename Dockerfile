# syntax=docker/dockerfile:1.7.0

FROM rust:alpine3.20 AS chef

WORKDIR /app

RUN apk add --no-cache \
    bash \
    build-base \
    g++ \
    git \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    perl \
    zig

ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN cargo install --locked cargo-zigbuild cargo-chef

FROM chef AS planner

COPY . .

RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --release --recipe-path recipe.json --target x86_64-unknown-linux-musl

COPY . .

ARG APP_NAME=hello_rust

# https://doc.rust-lang.org/cargo/reference/profiles.html
# 4 built-in profiles: dev, release, test, and bench
ARG PROFILE=${PROFILE:-dev}

ARG CARGO_TARGET_DIR=/app/target/${PROFILE}
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Build for musl target
RUN <<EOF
#!/usr/bin/env bash
cargo build --profile ${PROFILE} --target x86_64-unknown-linux-musl --bin ${APP_NAME}
if [ "${PROFILE}" = "dev" ]; then
    mv ${CARGO_TARGET_DIR}/x86_64-unknown-linux-musl/debug/${APP_NAME} /app/
elif [ "${PROFILE}" = "release" ]; then
    mv ${CARGO_TARGET_DIR}/x86_64-unknown-linux-musl/release/${APP_NAME} /app/
else
    echo "Unknown profile: ${PROFILE}"
    exit 1
fi
EOF

FROM alpine:3.20 AS runtime

ARG APP_NAME=hello_rust

WORKDIR /app

COPY --from=builder /app/${APP_NAME} /app/
COPY --from=builder /app/src/static /app/src/static

ARG ROCKET_PORT=8000
ENV ROCKET_PORT=${ROCKET_PORT}
EXPOSE ${ROCKET_PORT}

CMD ["/app/hello_rust"]
