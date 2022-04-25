#!/bin/sh

 name: Configure
      env:
        echo "## here in build_wheels_linux"
        PYPI_API_TOKEN: ${{ secrets.PYPI_API_TOKEN }}
	
# upload to PYPI.
    echo "check token...",$PYPI_API_TOKEN
    if [ -n "$PYPI_API_TOKEN" ]; then
	echo "pypi token is set"
    else
        echo "PYPI_API_Token is not taken"
    fi

