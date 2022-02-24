docker build . -t sol-stream:latest
docker run --rm -v $PWD:/code -it sol-stream:latest bash