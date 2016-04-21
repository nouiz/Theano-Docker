FROM nvidia/cuda:7.5-cudnn4-runtime

RUN apt-get update && apt-get install -y \
        pkg-config \
        libfreetype6-dev \
        libpng12-dev \
        python-numpy \
        python-pip \
        python-scipy \
        python-dev \
        python-nose \
        g++ \
        libopenblas-dev \
        git \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install \
        nose_parameterized \
        ipykernel \
        jupyter \
        matplotlib \
        && \
    python -m ipykernel.kernelspec

# Install the lastest Theano 0.8.X version
RUN pip install git+git://github.com/Theano/Theano.git@0.8.X

#RUN python -c "import theano;theano.test()"
COPY notebook /notebook

COPY start-notebook.sh /

EXPOSE 8888

WORKDIR "/notebook"

CMD ["/start-notebook.sh"]
