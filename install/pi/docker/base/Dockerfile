FROM arm32v7/python:3.7.3-stretch

RUN apt-get update \
  && apt-get install -y \
    autoconf \
    build-essential \
    cmake \
    curl \
    gcc \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    libffi6 \
    libffi-dev \
    lsof \
    make \
    mlocate \
    netcat \
    net-tools \
    openssl \
    pandoc \
    python3 \
    python3-dev \
    python3-pip \
    python3-tk \
    python-setuptools \
    python-virtualenv \
    python-pip \
    redis-tools \
    s3cmd \
    software-properties-common \
    strace \
    telnet \
    unzip \
    uuid-runtime \
    vim \
    wget

RUN echo "preparing virtualenv" \
  && pip install --upgrade virtualenvwrapper pip \
  && echo "creating virtualenv" \
  && virtualenv -p /usr/bin/python3 /opt/venv \
  && chmod 777 /opt/venv \
  && echo "setting up virtualenv" \
  && . /opt/venv/bin/activate \
  && pip install --upgrade setuptools pip

RUN echo "installing source" \
  && echo "activating venv" \
  && . /opt/venv/bin/activate \
  && cd /opt \
  && echo "cloning" \
  && git clone https://github.com/jay-johnson/donkeycar.git /opt/dc \
  && echo "using branch: d1" \
  && git checkout d1 \
  && echo "starting pip install pip install --upgrade -e ." \
  && cd /opt/dc \
  && pip install --upgrade -e . \
  && echo "pips:" \
  && pip list --format=columns \
  && echo "updating repo" \
  && ls -l /opt/dc

WORKDIR /opt/dc

ENTRYPOINT . /opt/venv/bin/activate \
  && ls -l /opt/dc
