FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y \
    build-essential \
    git \
    clang \
    clang-format \
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*


# ASUS
WORKDIR /build

ADD build.sh /build/build.sh

ENTRYPOINT [ "bash", "/build/build.sh" ]