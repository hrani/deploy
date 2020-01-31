all : moose3.1.4 pymoose

moose3.1.4 : Dockerfile.3.1.4
	docker build -t bhallalab/moose:3.1.4 -f Dockerfile.3.1.4 .

pymoose : Dockerfile
	docker build -t bhallalab/pymoose:3.2.git -f Dockerfile .
	docker build -t bhallalab/pymoose:latest -f Dockerfile .


run_pymoose:
	docker run -it bhallalab/pymoose:latest 
