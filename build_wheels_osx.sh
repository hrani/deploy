#!/bin/bash
set -e 

BRANCH=$(cat ./BRANCH)
VERSION=3.2.0.dev$(date +%Y%m%d)

echo "Create virtualenv by yourself"

brew install gsl 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MOOSE_SOURCE_DIR=`pwd`/moose-core

if [ ! -d $MOOSE_SOURCE_DIR ]; then
	git clone https://github.com/BhallaLab/moose-core -b $BRANCH --depth 10
fi
cd moose-core && git pull
WHEELHOUSE=$HOME/wheelhouse
mkdir -p $WHEELHOUSE

# Always prefer brew version.
for PYTHON in /usr/local/bin/python2 /usr/local/bin/python3; do
    if [ ! -f $PYTHON ]; then
        echo "Not found $PYTHON"
        continue
    fi

    $PYTHON -m pip install setuptools --upgrade
    $PYTHON -m pip install wheel --upgrade
    $PYTHON -m pip install numpy --upgrade
    $PYTHON -m pip install delocate --upgrade 
    $PYTHON -m pip install twine  --upgrade 
    PLATFORM=$($PYTHON -c "import distutils.util; print(distutils.util.get_platform())")
    ( 
        cd $MOOSE_SOURCE_DIR
        mkdir -p _build && cd _build
        echo "Building wheel for $PLATFORM"
        cmake -DVERSION_MOOSE=$VERSION \
            -DCMAKE_RELEASE_TYPE=Release \
            -DWITH_HDF=OFF \
            -DPYTHON_EXECUTABLE=$PYTHON \
            ..
        make -j4
        ( 
                cd python 
                ls *.py
                sed "s/from distutils.*setup/from setuptools import setup/g" setup.cmake.py > setup.wheel.py
                $PYTHON setup.wheel.py bdist_wheel -p $PLATFORM 
                # Now fix the wheel using delocate.
                delocate-wheel -w $WHEELHOUSE -v dist/*.whl
        )
        ls $WHEELHOUSE/pymoose*.whl
    )

    if [ -n "$PYPI_PASSWORD" ]; then
        python -m twine upload -u bhallalab -p $PYPI_PASSWORD $HOME/wheelhouse/pymoose*.whl
    fi
done
