# Theano-Docker

This repository contains Docker file for Theano

The Docker should start an Jupyter notebook

To build the Docker:

    docker build -t theano -f  Dockerfile.0.8.X.jupyter.cuda --rm=false .

Start it while allowing UNSECUR remote connection:

    nvidia-docker run -d -p 8888:8888 theano start-notebook.sh

Start it while allowing remote connection with a little bit of security:

    nvidia-docker run -d -p 8888:8888  -e PASSWORD="123abcChangeThis" theano start-notebook.sh

Start it while allowing more secur remote connection (Don't work yet):

    nvidia-docker run -d -p 8888:8888  -e PASSWORD="123abcChangeThis" -e USE_HTTPS=yes theano start-notebook.sh
