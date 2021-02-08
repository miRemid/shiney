.PHONY: build
build:
	go build -a -ldflags '-s' -o shiney

.PHONY: docker
docker:
	docker build -t shiney/api .