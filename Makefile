VERSION:=$(shell cat ./VERSION)

all : wheels


wheels : ./Dockerfile ./build_wheels_linux.sh ./build_wheels_osx.sh
	docker build -t bhallalab/pymoose_wheels:$(VERSION) .
	#docker build --no-cache -t bhallalab/pymoose_wheels:3.2.0 .
