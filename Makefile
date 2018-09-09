VERSION:=$(shell cat ./VERSION)

all : wheels

DOCKERFILE:="bhallalab/pymoose_wheels_$(USER):$(VERSION)"

wheels : ./Dockerfile ./build_wheels_linux.sh ./build_wheels_osx.sh
	mkdir -p $(HOME)/wheelhouse
	docker build  --no-cache \
	    -t $(DOCKERFILE) \
	    --build-arg PYPY_PASSWORD=$(PYPY_PASSWORD)  . | tee log
