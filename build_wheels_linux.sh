#!/bin/bash
set -e
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

REVISION=${1-chennapoda}
echo "Building revision $REVISION"

curl -O -sL https://github.com/BhallaLab/moose-core/archive/$REVISION.tar.gz
tar xvf $REVISION.tar.gz

MOOSE_SOURCE_DIR=$SCRIPT_DIR/moose-core-$REVISION

if [ ! -d $MOOSE_SOURCE_DIR ]; then
    echo "$MOOSE_SOURCE_DIR is not found."
    exit
fi

# Try to link statically.
GSL_STATIC_LIBS="/usr/local/lib/libgsl.a;/usr/local/lib/libgslcblas.a"
CMAKE=/usr/bin/cmake28

WHEELHOUSE=$HOME/wheelhouse
mkdir -p $WHEELHOUSE
for PYDIR in /opt/python/cp27-cp27m/ /opt/python/cp34-cp34m/ /opt/python/cp36-cp36m/; do
    PYVER=$(basename $PYDIR)
    mkdir -p $PYVER
    (
        cd $PYVER
        echo "Building using $PYDIR in $PYVER"
        PYTHON=$(ls $PYDIR/bin/python?.?)
        $PYTHON -m pip install numpy
        $CMAKE -DPYTHON_EXECUTABLE=$PYTHON  \
            -DGSL_STATIC_LIBRARIES=$GSL_STATIC_LIBS \
            -DVERSION_MOOSE=3.2.0rc1 \
            ${MOOSE_SOURCE_DIR}
        make -j4
        
        # Now build bdist_wheel
        cd python
        cp setup.cmake.py setup.py
        $PYDIR/bin/pip wheel . -w $WHEELHOUSE
    )
done

# now check the wheels.
for whl in $WHEELHOUSE/*.whl; do
    #auditwheel repair "$whl" -w $WHEELHOUSE
    auditwheel show "$whl"
done

ls -lh $WHEELHOUSE/*.whl
