#!/bin/bash
set -e -x

RELEASE=$(cat ./RELEASE)
BRANCH=$(cat ./BRANCH)
VERSION=$(date +%Y%m%d)

echo "Create virtualenv by yourself"

brew install gsl 
pip install setuptools --upgrade
pip install wheel --upgrade
pip install numpy --upgrade
pip install delocate --upgrade 
pip install twine  --upgrade 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MOOSE_SOURCE_DIR=`pwd`/moose-core

if [ ! -d $MOOSE_SOURCE_DIR ]; then
	git clone https://github.com/BhallaLab/moose-core -b $BRANCH --depth 10
fi
cd moose-core && git pull
WHEELHOUSE=$HOME/wheelhouse
mkdir -p $WHEELHOUSE

PLATFORM=$(python -c "import distutils.util; print(distutils.util.get_platform())")
( 
	cd $MOOSE_SOURCE_DIR
	mkdir -p _build && cd _build
	echo "Building wheel for $PLATFORM"
	cmake -DVERSION_MOOSE=$VERSION -DDEBUG=OFF -DCMAKE_RELEASE_TYPE=Release ..
	make -j`nproc`
	( 
		cd python 
		ls *.py
		sed "s/from distutils.*setup/from setuptools import setup/g" setup.cmake.py > setup.wheel.py
		python setup.wheel.py bdist_wheel -p $PLATFORM 
		# Now fix the wheel using delocate.
		delocate-wheel -w $WHEELHOUSE -v dist/*.whl
	)
	ls $WHEELHOUSE/pymoose*.whl
)

if [ -n "$PYPI_PASSWORD" ]; then
    python -m twine upload -u bhallalab -p $PYPI_PASSWORD $HOME/wheelhouse/pymoose*.whl
fi
