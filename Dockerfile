# Heavily Inspired from https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook
FROM nvidia/cuda:9.0-cudnn7-devel

ENV THEANO_VERSION 1.0.0
LABEL com.nvidia.theano.version="1.0.0"
ENV PYGPU_VERSION 0.7.5

USER root

# Install all OS dependencies for fully functional notebook server
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends \
    git \
    vim \
    jed \
    emacs \
    wget \
    build-essential \
    python-dev \
    ca-certificates \
    bzip2 \
    unzip \
    libsm6 \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    sudo \
    locales \
    libxrender1 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
#    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini && \
    echo "faafbfb5b079303691a939a747d7f60591f2143164093727e870b289a44d9872 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV NB_USER jovyan
ENV NB_UID 1000
#ENV LC_ALL en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US.UTF-8

# Create jovyan user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p /opt/conda && \
    chown jovyan /opt/conda

USER jovyan

# Setup jovyan home directory
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    mkdir /home/$NB_USER/.local && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

# Install conda as jovyan
ENV CONDA_VER 4.3.21
ENV CONDA_MD5 c1c15d3baba15bf50293ae963abef853
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh && \
    echo "$CONDA_MD5 *Miniconda3-${CONDA_VER}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${CONDA_VER}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${CONDA_VER}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --quiet --yes conda==${CONDA_VER} && \
    conda config --set auto_update_conda False && \
    conda clean -tipsy

# Install Jupyter notebook as jovyan
RUN conda install --quiet --yes \
    'notebook=5.0*' \
    terminado \
    mkl-service \
    && conda clean -tipsy

USER root

# Configure container startup as root
EXPOSE 8888
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]

# Add local files as late as possible to avoid cache busting
# Start notebook server
COPY start-notebook.sh /usr/local/bin/
COPY jupyter_notebook_config_secure.py /home/$NB_USER/.jupyter/jupyter_notebook_config.py
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter

# My own change

RUN apt-get update && apt-get install -y \
        libopenblas-dev \
        g++ \
        git \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install git+git://github.com/Theano/Theano.git@rel-$THEANO_VERSION
COPY theanorc /home/$NB_USER/.theanorc

RUN conda install -c mila-udem -y pygpu=$PYGPU_VERSION

# Switch back to jovyan to avoid accidental container runs as root
USER jovyan

COPY notebook notebook
RUN mkdir data && cd data && wget http://www.iro.umontreal.ca/~lisa/deep/data/mnist/mnist_py3k.pkl.gz -O mnist.pkl.gz

CMD ["start-notebook.sh", "notebook"]
