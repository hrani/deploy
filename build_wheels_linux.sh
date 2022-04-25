#!/bin/bash
X=$1
echo "X: $X" # X: default

echo "here in the build_wheel_LINUX FILE ", $PYPI_API_TOKEN
# upload to PYPI.
    echo "check token...",$PYPI_API_TOKEN
    if [ -n "$PYPI_API_TOKEN" ]; then
	echo "pypi token is set"
    else
        echo "PYPI_API_Token is not taken"
    fi

