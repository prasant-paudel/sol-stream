docker build . -t solana:latest
docker run --rm -v %cd%:/code -it solana:latest bash