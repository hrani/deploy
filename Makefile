VERSION:=$(shell cat ./VERSION)

all : wheels

wheels : ./Dockerfile ./build_wheels_linux.sh ./build_wheels_osx.sh
	mkdir -p /tmp/wheelhouse
	docker build -t bhallalab/pymoose_wheels:$(VERSION) \
	    --build-arg PYPY_PASSWORD=$(PYPY_PASSWORD)  . | tee log
