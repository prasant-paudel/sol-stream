docker build . -t solana:latest
docker run --rm -v $PWD:/code -it solana:latest bash