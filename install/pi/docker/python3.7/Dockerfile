FROM jayjohnson/arm32v7-base:latest

RUN python_version="3.7" \
  && python_build="${python_version}.3" \
  && echo "installing python ${python_version}" \
  && echo "downloading python ${python_build} source: https://www.python.org/ftp/python/${python_build}/Python-${python_build}.tar.xz" \
  && cd /opt \
  && wget https://www.python.org/ftp/python/${python_build}/Python-${python_build}.tar.xz -O /opt/Python-${python_build}.tar.xz -q \
  && echo "extracting tar: Python-${python_build}.tar.xz" \
  && tar xf Python-${python_build}.tar.xz \
  && echo "configuring" \
  && cd Python-${python_build} \
  && ./configure \
  && echo "building python ${python_build}" \
  && make -j 4 \
  && echo "make -j4 altinstall" \
  && sudo make -j4 altinstall \
  && echo "setting python ${python_build}" \
  && echo "update-alternatives --install /usr/bin/python python /usr/local/bin/python${python_version} 50" \
  && update-alternatives --install /usr/bin/python python /usr/local/bin/python${python_version} 50 \
  && echo "removing /opt/Python-${python_build}" \
  && sudo rm -r Python-${python_build} \
  && echo "removing /opt/Python-${python_build}.tar.xz" \
  && rm Python-${python_build}.tar.xz

RUN echo "preparing virtualenv" \
  && pip install --upgrade virtualenvwrapper pip \
  && echo "creating virtualenv using: ${python_version}: " \
  && virtualenv -p /usr/local/bin/python3.7 /opt/venv \
  && chmod 777 /opt/venv \
  && echo "setting up virtualenv" \
  && . /opt/venv/bin/activate \
  && pip install --upgrade setuptools pip

ENV VENV="/opt/venv"

ENTRYPOINT . /opt/venv/bin/activate \
  && ls -l /opt/dc
