VERSION:=$(shell cat ./VERSION)

all : wheels

wheels : ./Dockerfile ./build_wheels_linux.sh ./build_wheels_osx.sh
	mkdir -p /tmp/wheelhouse
	docker build -t bhallalab/pymoose_wheels:$(VERSION) \
	    -v /tmp/wheelhouse:/tmp/wheelhouse \
	    --build-arg PYPY_PASSWORD=$(PYPY_PASSWORD)  . | tee log
	#docker build --no-cache -t bhallalab/pymoose_wheels:3.2.0 .
