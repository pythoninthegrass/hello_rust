# hello_rust

Toy app to test cargo builds

## Minimum Requirements

* [cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
* [rust](https://www.rust-lang.org/tools/install)
* [docker](https://docs.docker.com/get-docker/)

## Quickstart

```bash
cargo build
cargo run
```

## Docker

```bash
docker build -t hello-rust .
docker run --name=hello-rust -it --rm \
    -p 8000:8000 \
    --env-file=.env \
    hello-rust
```

## Earthfile

```bash
# run a single target
earthly +build

# debug the build
earthly -i +build

# execute all targets needed to build the image
earthly +docker
```

## TODO

* benchmarks ([hyperfine](https://github.com/sharkdp/hyperfine?tab=readme-ov-file#warmup-runs-and-preparation-commands))
  * cargo
  * docker
  * earthfile
* earthly
  * enable push to registry
  * git credentials for private repo
  * secrets / .env file

## Further Reading

* [Making Your Docker Builds Faster with cargo-chef - Earthly Blog](https://earthly.dev/blog/cargo-chef/)
* [Tips For Faster Rust Compile Times | corrode Rust Consulting](https://corrode.dev/blog/tips-for-faster-rust-compile-times/)
* [Fast multi-arch Docker build for Rust projects :: vnotes](https://vnotes.pages.dev/fast-multi-arch-docker-for-rust/)
