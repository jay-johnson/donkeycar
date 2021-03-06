"""
Logger
"""
import os
import json
import logging.config


def setup(
        log_file_path=None,
        config=None,
        config_dict=None):
    """setup

    :param log_file_path: optional - path to output log file
    :param config: optional - path to log JSON-formatted config file
    :param config_dict: optional - log dictionary config
    """
    if log_file_path is None:
        log_file_path = os.path.expanduser(
            '~/donkey.log')

    config_dict = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'color_stream': {
                '()': 'colorlog.ColoredFormatter',
                'format': (
                    '%(log_color)s%(asctime)s - %(name)s - '
                    '%(levelname)s - %(message)s%(reset)s')
            },
            'simple': {
                'format': (
                    '%(asctime)s - %(name)s '
                    '- %(levelname)s - %(message)s')
            }
        },
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
                'level': 'INFO',
                'formatter': 'color_stream',
                'stream': 'ext://sys.stdout'
            },
            'error_file_handler': {
                'class': 'logging.handlers.RotatingFileHandler',
                'level': 'INFO',
                'formatter': 'simple',
                'filename': log_file_path,
                'maxBytes': 10485760,
                'backupCount': 20,
                'encoding': 'utf8'
            },
        },
        'root': {
            'level': 'DEBUG',
            'handlers': [
                # 'error_file_handler',
                'console'
            ]
        }
    }

    log_config = os.getenv(
        'DCLOGCONFIG',
        config)
    if log_config:
        config_dict = json.loads(
            open(log_config, 'r').read())

    logging.config.dictConfig(
        config_dict)


def get_logger(
        name):
    """
    Return a logger that will contextualize the logs with the name.

    :param name: name of the logger (usually the module's name)
    """
    logger = logging.getLogger(name)
    return logger


def get_log(
        name,
        log_file_path=None,
        config=None,
        config_dict=None):
    """get_log

    common call for creating logger

    **Log to Stdout**

    ::

        import datetime
        import donkeycar.log as log_utils

        log = log_utils.get_log(
            name=__name__)

        log.info(
            'test log message {}'.format(
                datetime.datetime.utcnow()))

    **Log to Splunk using the Local Fluent Bit Forwarder**

    ::

        import datetime
        import donkeycar.log as log_utils

        log = log_utils.get_log(
            name='test-fluent-bit-logging',
            config='/opt/dc/donkeycar/splunk/log_config.json')

        log.info(
            'test log message for splunk {}'.format(
                datetime.datetime.utcnow()))

    **Supported Environment Variables**

    ::

        export DCLOGCONFIG=PATH_TO_LOG_CONFIG_DICT

    :param name: name of the logger (usually the module's name)
    :param log_file_path: optional - path to output log file
    :param config: optional - path to log JSON-formatted config file
        (None by default, and sample included in the repo:
        /opt/dc/donkeycar/splunk/log_config.json)
    :param config_dict: optional - log dictionary config
    """
    log_config = config
    if not log_config:
        log_config = os.getenv(
            'DCLOGCONFIG',
            None)
    setup(
        log_file_path=log_file_path,
        config=log_config,
        config_dict=config_dict)
    return get_logger(
        name=name)
