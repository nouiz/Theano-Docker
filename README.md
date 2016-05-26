# Theano-Docker

This repository contains Docker file for Theano

The Docker should start a Jupyter notebook

There is 2 docker files. One simple and one with more security enabled.

To build the Docker:

    docker build -t theano_secure -f  Dockerfile.0.8.X.jupyter.cuda.simple .  # simple version
    docker build -t theano_simple -f  Dockerfile.0.8.X.jupyter.cuda .  # more secure version

Start the simple one while allowing UNSECURE remote connection:

    nvidia-docker run -d -p 8888:8888 theano_simple start-notebook.sh
    # Then open your browser at http://HOST:8888

Start it while allowing remote connection with a little bit of security:

    nvidia-docker run -d -p 8888:8888  -e PASSWORD="123abcChangeThis" theano_secure start-notebook.sh
    # Then open your browser at http://HOST:8888

Start it while allowing more secure remote connection:

    nvidia-docker run -d -p 8888:8888  -e PASSWORD="123abcChangeThis" -e USE_HTTPS=yes theano_secure start-notebook.sh
    # Then open your browser at https://HOST:8888
