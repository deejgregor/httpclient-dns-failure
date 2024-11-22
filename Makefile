help:
	@echo "Usage:" >&2
	@echo "    make break -- make the HttpClient request fail by breaking DNS resolution" >&2
	@echo "    make work -- let the HttpClient request succeed by leaving DNS resolution alone" >&2
	@echo "    make clean -- remove the Docker image we create" >&2

.PHONY: break
break: container
	docker run -it --rm groovy:tcpdump

.PHONY: work
work: container
	docker run -it --rm -e DO_NOT_BREAK=true groovy:tcpdump

.PHONY: container
container:
	docker build -t groovy:tcpdump .

.PHONY: clean
clean:
	docker image rm groovy:tcpdump
