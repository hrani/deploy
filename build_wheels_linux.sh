#!/bin/sh

set -e -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NPROC=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
NUM_WORKERS=$((NPROC))
MAKEOPTS="-j$NUM_WORKERS"

# Place to store wheels.

WHEELHOUSE=${1-$HOME/wheelhouse}
echo "Path to store wheels : $WHEELHOUSE"
mkdir -p $WHEELHOUSE

# tag on github and revision number. Make sure that they are there.
BRANCH=$(cat ./BRANCH)
VERSION="4.0.0dev$(date +%Y%m%d)"

# Create a test script and upload.
TESTFILE=/tmp/test.py
cat <<EOF >$TESTFILE
import moose
import moose.utils as mu
print( moose.__version__ )
moose.reinit()
moose.start( 1 )
EOF


echo "Building version $VERSION, from branch $BRANCH"

if [ ! -f /usr/local/lib/libgsl.a ]; then 
    #wget --no-check-certificate ftp://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz 
    curl -O https://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz
    tar xvf gsl-2.4.tar.gz 
    cd gsl-2.4 
    CFLAGS=-fPIC ./configure --enable-static && make $MAKEOPTS
    sudo make install 
    cd ..
fi 

MOOSE_SOURCE_DIR=$SCRIPT_DIR/moose-core
if [ -d $MOOSE_SOURCE_DIR ]; then
  cd $MOOSE_SOURCE_DIR && git checkout $BRANCH && git pull origin $BRANCH
  rm -rf dist
else
  git clone https://github.com/bhallalab/moose-core $MOOSE_SOURCE_DIR \
    --depth 1 --branch $BRANCH
fi

# Try to link statically.
GSL_STATIC_LIBS="/usr/local/lib/libgsl.a;/usr/local/lib/libgslcblas.a"
CMAKE=/usr/bin/cmake3

# Build wheels here.
PY27=$(ls /usr/local/bin/python$_py)
PY35=$(ls /usr/local/bin/python$_py)
PY36=$(ls /usr/local/bin/python?.?)
PY37=$(ls /usr/local/bin/python?.?)
PY38=$(ls /usr/local/bin/python?.?)

for PYTHON in $PY38 $PY37 $PY36 $PY35 $PY27; do
  echo "========= Building using $PYTHON ..."
  $PYTHON -m pip install pip setuptools --upgrade
  if [[ "$PYV" -eq "27" ]]; then
    $PYTHON -m pip install numpy==1.15
    $PYTHON -m pip install matplotlib==2.2.3
  else
    $PYTHON -m pip install numpy twine
    $PYTHON -m pip install matplotlib
  fi

  $PYTHON -m pip install twine

  # Removing existing pymoose if any.
  $PYTHON -m pip uninstall pymoose -y || echo "No pymoose"

  cd $MOOSE_SOURCE_DIR
  export GSL_USE_STATIC_LIBRARIES=1
  $PYTHON setup.py build_ext 
  $PYTHON setup.py bdist_wheel --skip-build 
  ( 
      echo "Install and test this wheel"
      # NOTE: Not sure why I have to do this. But cant install wheel from build
      # directory.
      cd /tmp
      $PYTHON -m pip install $MOOSE_SOURCE_DIR/dist/*.whl 
      $PYTHON $TESTFILE
      mv $MOOSE_SOURCE_DIR/dist/*.whl $WHEELHOUSE
      rm -rf $MOOSE_SOURCE_DIR/dist/*.whl
  )
done

# List all wheels.
ls -lh $WHEELHOUSE/*.whl

# now check the wheels.
for whl in $WHEELHOUSE/pymoose*.whl; do
    auditwheel show "$whl"
    # Fix the tag and remove the old wheel.
    auditwheel repair "$whl" -w $WHEELHOUSE && rm -f "$whl"
done

# upload to PYPI.
$PY38 -m pip install twine
TWINE="$PY38 -m twine"
for whl in `find $WHEELHOUSE -name "pymoose*.whl"`; do
    # If successful, upload using twine.
    if [ -n "$PYMOOSE_PYPI_PASSWORD" ]; then
        $TWINE upload $whl \
          --user bhallalab \
          --password $PYMOOSE_PYPI_PASSWORD --skip-existing
    else
        echo "PYPI password is not set"
    fi
done
