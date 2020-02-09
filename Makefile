VERSION:=$(shell cat ./VERSION)

all : wheels

DOCKERFILE:="bhallalab/pymoose_wheels_$(USER):$(VERSION)"

wheels : ./Dockerfile ./build_wheels_linux.sh 
	mkdir -p $(HOME)/wheelhouse
	docker build \
	    -t $(DOCKERFILE) \
	    --build-arg PYMOOSE_PYPI_PASSWORD=$(PYMOOSE_PYPI_PASSWORD) . 

run:
	docker run -it $(DOCKERFILE) /bin/bash
