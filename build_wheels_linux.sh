#!/bin/sh

set -e 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Place to store wheels.
WHEELHOUSE=${1-$HOME/wheelhouse}
echo "Path to store wheels : $WHEELHOUSE"
mkdir -p $WHEELHOUSE

# tag on github and revision number. Make sure that they are there.
BRANCH=$(cat ./BRANCH)
VERSION="3.2.0.dev$(date +%Y%m%d)"

echo "Building version $REVISION, from branch $BRANCH"

if [ ! -f /usr/local/lib/libgsl.a ]; then 
    #wget --no-check-certificate ftp://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz 
    /usr/local/bin/curl -O https://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz
    tar xvf gsl-2.4.tar.gz 
    cd gsl-2.4 
    CFLAGS=-fPIC ./configure --enable-static && make 
    make install 
    cd ..
fi 

MOOSE_SOURCE_DIR=$SCRIPT_DIR/moose-core

if [ ! -d $MOOSE_SOURCE_DIR ]; then
    git clone https://github.com/BhallaLab/moose-core --depth 10 --branch $BRANCH
fi

# Try to link statically.
GSL_STATIC_LIBS="/usr/local/lib/libgsl.a;/usr/local/lib/libgslcblas.a"
CMAKE=/usr/bin/cmake28

for PYV in 36 27; do
    PYDIR=/opt/python/cp${PYV}-cp${PYV}m
    PYVER=$(basename $PYDIR)
    mkdir -p $PYVER
    (
        cd $PYVER
        echo "Building using $PYDIR in $PYVER"
        PYTHON=$(ls $PYDIR/bin/python?.?)
        $PYTHON -m pip install numpy matplotlib twine
        $PYTHON -m pip uninstall pymoose -y
	git pull || echo "Failed to pull $BRANCH"
        $CMAKE -DPYTHON_EXECUTABLE=$PYTHON  \
            -DGSL_STATIC_LIBRARIES=$GSL_STATIC_LIBS \
            -DVERSION_MOOSE=$VERSION \
            ${MOOSE_SOURCE_DIR}
        make 
        
        # Now build bdist_wheel
        cd python
        cp setup.cmake.py setup.py
        $PYDIR/bin/pip wheel . -w $WHEELHOUSE 
    )
done

# now check the wheels.
for whl in $WHEELHOUSE/*.whl; do
    auditwheel show "$whl"
done

echo "Installing before testing ... "
/opt/python/cp27-cp27m/bin/pip install $WHEELHOUSE/pymoose-$VERSION-py2-none-any.whl
/opt/python/cp36-cp36m/bin/pip install $WHEELHOUSE/pymoose-$VERSION-py3-none-any.whl
for PYV in 36 27; do
    PYDIR=/opt/python/cp${PYV}-cp${PYV}m
    PYTHON=$(ls $PYDIR/bin/python?.?)
    echo " -- Installing for $PYTHON ... "
    $PYTHON -c 'import moose; print( moose.__version__ )'
done
	

ls -lh $WHEELHOUSE/*.whl
if [ ! -z PYPI_PASSWORD ]; then
    /opt/python/cp27-cp27m/bin/python -m twine upload $WHEELHOUSE/pymoose*.whl --user bhallalab  --password $PYPI_PASSWORD
fi
