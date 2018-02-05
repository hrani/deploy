#!/bin/bash
set -e
set -x

brew install gsl 
brew install cmake
sudo easy_install pip --upgrade
sudo pip install pip --upgrade 
sudo pip install delocate 
sudo pip install twine

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MOOSE_SOURCE_DIR=/tmp/moose-core

# Clone git or update.
if [ ! -d $MOOSE_SOURCE_DIR ]; then
    git clone https://github.com/BhallaLab/moose-core --depth 10 $MOOSE_SOURCE_DIR
else
    cd $MOOSE_SOURCE_DIR && git pull
fi

cd $MOOSE_SOURCE_DIR

mkdir _build
cd _build
cmake .. && make -j3 && cd python && python setup.cmake.py bdist_wheel 
