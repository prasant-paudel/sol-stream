# Ubuntu 20.04
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl

# Install Git
sudo apt install git

# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/v1.9.8/install)"

# Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Node.js 

# Install Postgress