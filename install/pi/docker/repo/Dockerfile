FROM jayjohnson/arm32v7-python37-venv:latest

RUN echo "installing source" \
  && echo "activating venv" \
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
  && git checkout d1 \
  && cd /opt/dc \
  && pip install scipy -vv \
  && echo "starting pip install pip install --upgrade -e ." \
  && cd /opt/dc \
  && pip install --upgrade -evv . \
  && echo "pips:" \
  && pip list --format=columns \
  && echo "updating repo" \
  && ls -l /opt/dc

ENTRYPOINT . /opt/venv/bin/activate \
  && ls -l /opt/dc
