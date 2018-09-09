#!/usr/bin/env bash
set -x 
set -e 

echo "Getting supported repository."
if [ ! -d home:moose ]; then
    osc co home:moose
fi

function buildRepo {
    echo "  Building for $1" 
    osc build "$1"
}

(
    cd home:moose/pymoose
    osc update
    REPOS=$(osc repositories | cut -d' ' -f 1)
    for _repo in $REPOS; do
        buildRepo $_repo 
    done
)
