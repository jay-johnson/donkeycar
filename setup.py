from setuptools import setup, find_packages
import os


# include the non python files


def package_files(directory, strip_leading):
    paths = []
    for (path, directories, filenames) in os.walk(directory):
        for filename in filenames:
            max_len = len(strip_leading)
            package_file = os.path.join(path, filename)
            paths.append(package_file[max_len:])
    return paths


car_templates = ["templates/*"]
web_controller_html = package_files(
    "donkeycar/parts/controllers/templates",
    "donkeycar/"
)


extra_files = car_templates + web_controller_html
print("extra_files", extra_files)
base_module_path = "donkeycar.management.base"

setup(
    name="donkeycar",
    version="2.6.0.t",
    description=(
        "work-in-progress for learning about donkey cars: "
        "a self driving library for python."
    ),
    url="https://github.com/jay-johnson/donkeycar",
    author="Will Roscoe",
    author_email="wroscoe@gmail.com",
    license="MIT",
    entry_points={
        "console_scripts": [f"dk={base_module_path}:execute_from_command_line"]
    },
    install_requires=[
        "black",
        "colorlog",
        "docopt",
        "docker-compose",
        "eventlet",
        "h5py",
        "flask",
        "flake8",
        "keras",
        "moviepy",
        "numpy",
        "paho-mqtt",
        "pandas",
        "pillow",
        "prettytable",
        "python-socketio",
        "pycodestyle",
        "requests",
        "tornado==4.5.2",
    ],
    extras_require={
        "pi": ["picamera", "Adafruit_PCA9685", "RPi.GPIO"],
        "pc": ["matplotlib", "scikit-learn"],
    },
    package_data={"donkeycar": extra_files},
    include_package_data=True,
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        "Development Status :: 3 - Alpha",
        # Indicate who your project is intended for
        "Intended Audience :: Developers",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        # Pick your license as you wish (should match "license" above)
        "License :: OSI Approved :: MIT License",
        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
    ],
    keywords="selfdriving cars drive",
    packages=find_packages(
        exclude=(
            [
                "tests",
                "docs",
                "site",
                "env"
            ]
        )
    ),
)
