#!/bin/sh


# upload to PYPI.
    echo "check token",$PYPI_API_TOKEN
    if [ -n "$PYPI_API_TOKEN" ]; then
	echo "pypi token is set"
    else
        echo "PYPI password is not set"
    fi
done
