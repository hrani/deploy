#!/bin/bash

set -e -x

RELEASE=v3.2.1
VERSION=3.2.1

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

curl -sL -O https://github.com/BhallaLab/moose-core/archive/${RELEASE}.tar.gz
tar xvf ${RELEASE}.tar.gz

MOOSE_SOURCE_DIR=`pwd`/moose-core-$VERSION
mkdir -p $MOOSE_SOURCE_DIR/_build

PLATFORM=$(python -c "import distutils.util; print(distutils.util.get_platform())")
echo "Building wheel for $PLATFORM"
cd $MOOSE_SOURCE_DIR/_build
cmake -DVERSION_MOOSE=$VERSION -DDEBUG=OFF -DCMAKE_RELEASE_TYPE=Release ..
make -j3 
cd python && python setup.cmake.py bdist_wheel -p $PLATFORM  

# Now fix the wheel using delocate.
rm -rf $HOME/wheelhouse
mkdir -p $HOME/wheelhouse
cd $MOOSE_SOURCE_DIR/_build/python/ && delocate-wheel -w $HOME/wheelhouse -v dist/*.whl
ls $HOME/wheelhouse/pymoose*.whl

if [ -n "$PYPI_PASSWORD" ]; then
    python -m twine upload -u bhallalab -p $PYPI_PASSWORD $HOME/wheelhouse/pymoose*.whl
fi
