FROM jayjohnson/arm32v7-python37-venv:latest

RUN echo "installing source" \
  && echo "activating venv" \
  && apt-get install -y gfortran libblas-dev liblapack-dev \
  && . /opt/venv/bin/activate \
  && echo "checking python version:" \
  && python --version \
  && echo "checking python path:" \
  && which python \
  && pyver=$(python --version | grep 3.7 | wc -l) \
  && if [ "${pyver}" = "0" ]; then echo "\nBase image failed setting up virtual env:\nmissing Python 3.7 in virtual env:\n$(which python)\npython version: $(python --version)\n"; exit 1; fi \
  && cd /opt \
  && echo "cloning" \
  && git clone https://github.com/jay-johnson/donkeycar.git /opt/dc \
  && cd /opt/dc \
  && echo "using branch: d1" \
  && git checkout d1

RUN echo "installing initial pips that take a long time: numpy and scipy" \
  && cd /opt/dc \
  && . /opt/venv/bin/activate \
  && echo "installing numpy" \
  && pip install numpy -v \
  && echo "installing scipy" \
  && pip install scipy -v
  && echo "installing pandas" \
  && pip install pandas \

RUN echo "building repo" \
  && . /opt/venv/bin/activate \
  && cd /opt/dc \
  && echo "starting pip install pip install --upgrade -e ." \
  && pip install --upgrade -e . \
  && echo "pips:" \
  && pip list --format=columns \
  && echo "updating repo" \
  && ls -l /opt/dc

ENTRYPOINT . /opt/venv/bin/activate \
  && ls -l /opt/dc
