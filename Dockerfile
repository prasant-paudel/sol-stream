FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=NONINTERACTIVE

# Change apt Sources to Local
RUN sed -i 's/archive.ubuntu.com/ubuntu.ntc.net.np/g' /etc/apt/sources.list
RUN apt update && apt upgrade -y

# Install Utilities
RUN apt install -y \
    git \
    curl \
    wget \
    lsb-release \
    xz-utils \
    software-properties-common

# Install PostgreSQL
RUN apt install -y postgresql

# # Install Node Js v16.14.0
# RUN wget https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-x64.tar.xz
# RUN tar -xvf node-v16.14.0-linux-x64.tar.xz && rm node-v16.14.0-linux-x64.tar.xz
# RUN mv node-v16.14.0-linux-x64 /opt/node
# RUN ln -s /opt/node/bin/node /usr/bin/node

# Install npm
RUN apt install -y npm

# Install Solana v1.9.8
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.9.8/install)"
ENV PATH="$PATH:/root/.local/share/solana/install/releases/1.9.8/solana-release/bin/"

# Install Rust toolchain 1.55.0 (compatible with LLVM 12)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# RUN /root/.cargo/bin/rustup override set 1.55.0

# For tried-and-true gcc toolchain
# -> Solution to: linker `cc` not found
RUN apt install -y build-essential

# Install LLVM 13 (for llvm-sys v130.x.x)
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh

# libelf
RUN apt install -y libelf-dev
ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

# Build Program
WORKDIR /code
RUN git clone https://github.com/SushantChandla/sol-stream-program.git
WORKDIR /code/sol-stream-program
RUN /root/.cargo/bin/cargo clean
RUN /root/.cargo/bin/cargo build-bpf --manifest-path=Cargo.toml --bpf-out-dir=dist/program


# # Build frontend
# WORKDIR /code
# RUN git clone https://github.com/SushantChandla/sol-stream-frontend.git
# WORKDIR /code/sol-stream-frontend
# RUN npm ci

# # Build Backend
# WORKDIR /code
# RUN git clone https://github.com/SushantChandla/sol-stream-backend.git
# WORKDIR /code/sol-stream-backend
