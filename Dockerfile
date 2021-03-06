FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=NONINTERACTIVE

# Change apt Sources to Local
RUN sed -i 's/archive.ubuntu.com/ubuntu.ntc.net.np/g' /etc/apt/sources.list
RUN apt update && apt upgrade -y

# Install Utilities
RUN apt install -y git curl wget
RUN apt install -y lsb-release software-properties-common

# Install PostgreSQL
RUN apt install -y postgresql

# Install Node Js v16.14.0
RUN wget https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-x64.tar.xz
RUN tar -xvf node-v16.14.0-linux-x64.tar.xz && rm node-v16.14.0-linux-x64.tar.xz
RUN mv node-v16.14.0-linux-x64 /opt/node
ENV PATH="$PATH:/opt/node/bin"
RUN npm install -g yarn

# Install Solana v1.9.8
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.9.8/install)"
ENV PATH="$PATH:/root/.local/share/solana/install/releases/1.9.8/solana-release/bin/"

# Install Rust toolchain 1.58.1 (compatible with LLVM 13)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN /root/.cargo/bin/rustup override set 1.58.1

# For tried-and-true gcc toolchain
# -> Solution to: linker `cc` not found
RUN apt install -y build-essential

# Install LLVM 13 (for llvm-sys v130)
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh # 13.0.0

# libelf
RUN apt install -y libelf-dev
ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

# Local solana cluster
RUN apt install -y libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make

# Set config to Localnet
RUN solana config set --url http://127.0.0.1:8899

# Install npm serve
RUN npm i -g serve

# Make directory code
RUN mkdir /code

# Build Program
WORKDIR /code
RUN git clone https://github.com/SushantChandla/sol-stream-program.git
WORKDIR /code/sol-stream-program
ENV PATH="$PATH:/root/.cargo/bin"
RUN cargo clean
RUN cargo build-bpf --manifest-path=Cargo.toml --bpf-out-dir=dist/program

# Build frontend
WORKDIR /code
RUN git clone https://github.com/SushantChandla/sol-stream-frontend.git
WORKDIR /code/sol-stream-frontend
RUN yarn install
RUN yarn build

# Build Backend
WORKDIR /code
RUN git clone https://github.com/SushantChandla/sol-stream-backend.git
WORKDIR /code/sol-stream-backend

# Error:
# -> /usr/bin/ld: cannot find -lpq
# -> /usr/bin/ld: cannot find -lsqlite3
# -> /usr/bin/ld: cannot find -lmysqlclient
# Solution:
RUN apt install -y libpq-dev libsqlite3-dev libmysqlclient-dev

RUN cargo install diesel_cli
RUN echo DATABASE_URL=postgres://sol_stream_user:sol_stream_password@localhost/sol_stream_indexer > .env

# Postgresql Setup
RUN service postgresql start && echo "CREATE USER sol_stream_user WITH PASSWORD 'sol_stream_password';" | su postgres -c psql
RUN service postgresql start && echo "CREATE DATABASE sol_stream_indexer;" | su postgres -c psql
RUN service postgresql start && echo "GRANT ALL PRIVILEGES ON DATABASE sol_stream_indexer TO sol_stream_user;" | su postgres -c psql

RUN service postgresql start && diesel setup
RUN diesel migration generate Stream

# Change server address to global
RUN echo '[global]\naddress = "0.0.0.0"' > Rocket.toml

# service postresql start && cargo run
