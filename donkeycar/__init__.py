import sys
import os

from . import parts  # noqa
from .vehicle import Vehicle  # noqa
from .memory import Memory  # noqa
from . import utils  # noqa
from . import config  # noqa
from . import contrib  # noqa
from .config import load_config  # noqa

__version__ = '2.6.0t'

if os.getenv(
        'DCDEBUG',
        '0') == '1':
    print(
        'using donkey v{} ...'.format(
            __version__))

if sys.version_info.major < 3:
    msg = (
        'Donkey Requires Python 3.4 '
        'or greater. You are using {}'.format(
            sys.version))
    raise ValueError(msg)
