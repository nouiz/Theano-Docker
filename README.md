# Theano-Docker

This repository contains Docker file for Theano

The Docker should start a Jupyter notebook

To build the Docker:

    docker build -t theano -f  Dockerfile.0.8.X.jupyter.cuda .

Start it while allowing UNSECURE remote connection:

    nvidia-docker run -d -p 8888:8888 theano start-notebook.sh
    # Then open your browser at http://HOST:8888

Start it while allowing remote connection with a little bit of security:

    nvidia-docker run -d -p 8888:8888  -e PASSWORD="123abcChangeThis" theano start-notebook.sh
    # Then open your browser at http://HOST:8888

Start it while allowing more secure remote connection:

    nvidia-docker run -d -p 8888:8888  -e PASSWORD="123abcChangeThis" -e USE_HTTPS=yes theano start-notebook.sh
    # Then open your browser at https://HOST:8888
