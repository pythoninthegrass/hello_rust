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

# build for arm64 and amd64
earthly +all

# push to registry
earthly --push +<target> 

# interactive shell
earthly --interactive +<target>
```

## Benchmarks

```bash
# install hyperfine
brew install hyperfine

# run benchmarks (native arch)
hyperfine \
    --prepare 'docker rmi ghcr.io/pythoninthegrass/hello_rust || true' \
    --warmup 1 \
    --runs 2 \
    'earthly +build'
    --export-markdown earthly_bench.md

# run docker and earthly benchmarks via task
task benchmark
```

## TODO

* benchmarks ([hyperfine](https://github.com/sharkdp/hyperfine?tab=readme-ov-file#warmup-runs-and-preparation-commands))
  * cargo
  * ~~docker~~
  * ~~earthfile~~
* earthly
  * ~~enable push to registry~~
  * ~~git credentials for private repo~~
  * secrets / .env file

## Further Reading

* [Tips For Faster Rust Compile Times | corrode Rust Consulting](https://corrode.dev/blog/tips-for-faster-rust-compile-times/)
* [Making Your Docker Builds Faster with cargo-chef - Earthly Blog](https://earthly.dev/blog/cargo-chef/)
* [Fast multi-arch Docker build for Rust projects :: vnotes](https://vnotes.pages.dev/fast-multi-arch-docker-for-rust/)
* [Kobzol/cargo-wizard: Cargo subcommand for configuring Cargo projects for best performance.](https://github.com/Kobzol/cargo-wizard?tab=readme-ov-file#usage)
* [Speeding up the Rust edit-build-run cycle | David Lattimore](https://davidlattimore.github.io/posts/2024/02/04/speeding-up-the-rust-edit-build-run-cycle.html)
* [How-to compile rust faster - Rust.Careers Rust Blog](https://blog.rust.careers/post/compile_rust_faster/)
* [Accelerating Rust compilation times: Dynamic linking, code generation and cache](https://nicoan.github.io/posts/accelerating_compile_times/)
