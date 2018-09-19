#!/usr/bin/env bash
set -x 
set -e 

REPOS="xUbuntu_18.04 xUbuntu_16.04 xUbuntu_14.04 \
    openSUSE_Tumbleweed openSUSE_Leap_15.0\
    SLE_15 \
    RHEL_7 \
    Fedora_Rawhide Fedora_28 \
    Debian_9.0 \
    CentOS_7"

echo "Getting supported repository."
if [ ! -d home:moose/pymoose ]; then
    osc co home:moose pymoose
fi

function buildRepo {
    echo "  Building for $1" 
    ROOTDIR=$HOME/.OBS/build
    mkdir -p $ROOTDIR
    echo "Building in $ROOTDIR"
    osc build --noverify --trust-all-projects  \
        --root=$ROOTDIR \
        "$1"
}

(
    cd home:moose/pymoose
    osc update
    for _repo in $REPOS; do
        echo " --- $_repo"
        buildRepo $_repo
    done
)
