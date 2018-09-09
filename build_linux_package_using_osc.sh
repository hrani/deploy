#!/usr/bin/env bash
echo "Getting supported repository."
if [ ! -d home:moose ]; then
    osc co home:moose
fi
cd home:moose
osc update
