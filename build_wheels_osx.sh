#!/bin/bash

set -e
set -x

brew install gsl 

sudo /usr/bin/easy_install virtualenv

# setup virtualenv
python -m virtualenv -p /usr/bin/python $HOME/python2
source $HOME/python2/bin/activate

pip install setuptools --upgrade
pip install numpy --upgrade
pip install delocate --upgrade 
pip install twine  --upgrade 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MOOSE_SOURCE_DIR=/tmp/moose-core

# Clone git or update.
if [ ! -d $MOOSE_SOURCE_DIR ]; then
    git clone https://github.com/BhallaLab/moose-core --depth 10 $MOOSE_SOURCE_DIR
else
    cd $MOOSE_SOURCE_DIR && git pull
fi

cd $MOOSE_SOURCE_DIR
mkdir -p _build && cd _build

PLATFORM=$(python -c "import distutils.util; print(distutils.util.get_platform())")
echo "Building wheel for $PLATFORM"
cmake -DVERSION_MOOSE=3.2.0rc1 .. && make -j3 && cd python && python setup.cmake.py bdist_wheel -p $PLATFORM

# Now fix the wheel using delocate.
rm -rf $HOME/wheelhouse
mkdir -p $HOME/wheelhouse
cd $MOOSE_SOURCE_DIR/_build/python/ && delocate-wheel -w $HOME/wheelhouse -v dist/*.whl
ls $HOME/wheelhouse/pymoose*.whl
if [ -z $PYPI_PASSWORD ]; then
    python -m twine upload -u bhallalab -p $PYPI_PASSWORD $HOME/wheelhouse/pymoose*.whl
fi
