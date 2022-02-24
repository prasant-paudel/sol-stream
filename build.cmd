docker build . -t sol-stream:latest
docker run --rm -p 3000:3000 -p 8000:8000 -p 8899:8899 -p 5432:5432 -it sol-stream:latest bash
