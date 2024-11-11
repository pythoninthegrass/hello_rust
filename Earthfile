VERSION 0.8

ARG --global APP_NAME="hello_rust"
ARG --global PROFILE=release

all:
	BUILD \
		--platform=linux/amd64 \
		--platform=linux/arm64 \
		+docker

install:
	FROM rust:alpine3.20
	RUN apk add --no-cache \
		autoconf \
		automake \
		bash \
		build-base \
		clang \
		cmake \
		findutils \
		g++ \
		gcc \
		git \
		libtool \
		make \
		mold \
		musl-dev \
		openssl-dev \
		openssl-libs-static \
		perl \
		pkgconfig \
		zig

	ENV PKG_CONFIG_SYSROOT_DIR=/
	ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
	ENV CARGO_INCREMENTAL=0
	ENV CARGO_BUILD_JOBS=12
	ENV RUSTFLAGS="-Awarnings -C target-feature=-crt-static -C link-arg=-fuse-ld=mold -C link-arg=-s"

	RUN cargo install --locked cargo-zigbuild

source:
	FROM +install
	WORKDIR /app
	COPY --keep-ts --dir src Cargo.toml Cargo.lock .
	SAVE ARTIFACT ./src/static static

build:
	FROM +install
	ARG TARGETPLATFORM
	ARG PROFILE=$PROFILE

	ARG RUST_BACKTRACE=full

	ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
	ENV SSL_CERT_DIR=/etc/ssl/certs
	ENV OPENSSL_STATIC=1
	ENV OPENSSL_LIB_DIR=/usr/lib
	ENV OPENSSL_INCLUDE_DIR=/usr/include

	WORKDIR /build
	COPY --keep-ts --dir src Cargo.toml Cargo.lock .

	# Set target architecture and build
	RUN --no-cache \
		if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
			export TARGET_ARCH="x86_64-unknown-linux-musl"; \
		else \
			export TARGET_ARCH="aarch64-unknown-linux-musl"; \
		fi \
		&& echo "Building for $TARGET_ARCH" \
		&& cargo zigbuild --profile ${PROFILE} --target ${TARGET_ARCH} --bin ${APP_NAME} \
		&& mkdir -p /output \
		&& cp target/${TARGET_ARCH}/${PROFILE}/${APP_NAME} /output/

	SAVE ARTIFACT /output/${APP_NAME} ${APP_NAME}-${TARGETPLATFORM}

docker:
	ARG REGISTRY="ghcr.io"
	ARG ORGANIZATION="pythoninthegrass"
	ARG REPOSITORY="hello_rust"
	ARG TAG="latest"
	ARG TARGETPLATFORM

	FROM --platform=$TARGETPLATFORM alpine:3.20.3
	WORKDIR /app

	RUN apk add --no-cache \
		ca-certificates \
		libgcc \
		libssl3 \
		libcrypto3

	RUN addgroup -S appgroup && adduser -S appuser -G appgroup

	COPY \
		+build/${APP_NAME}-${TARGETPLATFORM} \
		./${APP_NAME}
	COPY +source/static static

	RUN chown -R appuser:appgroup /app

	USER appuser
	ARG ROCKET_PORT=8000
	ENV ROCKET_PORT=$ROCKET_PORT
	EXPOSE $ROCKET_PORT
	ENTRYPOINT ["/app/hello_rust"]
	SAVE IMAGE --push "${REGISTRY}/${ORGANIZATION}/${REPOSITORY}:${TAG}"
