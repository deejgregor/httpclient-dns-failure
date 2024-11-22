help:
	@echo "Usage:" >&2
	@echo "    make work -- let the HttpClient request succeed by leaving DNS resolution alone" >&2
	@echo "    make break -- make the HttpClient request fail by breaking DNS resolution with DNS timeout > HttpRequest timeout" >&2
	@echo "    make break-fast-timeout -- make the HttpClient request fail by breaking DNS resolution with DNS timeout < HttpRequest timeout" >&2
	@echo "    make work-on-retry -- make the HttpClient request succeed when querying a second DNS server" >&2
	@echo "    make clean -- remove the Docker image we create" >&2

.PHONY: work
work: container
	docker run -it --rm groovy:tcpdump

.PHONY: break
break: container
	docker run -it --rm -e BREAK=true groovy:tcpdump

.PHONY: break-fast-timeout
break-fast-timeout: container
	docker run -it --rm -e BREAK=true -e FAST_TIMEOUT=true groovy:tcpdump

.PHONY: work-on-retry
work-on-retry: container
	docker run -it --rm -e BREAK=true -e FAST_TIMEOUT=true -e SECOND_NAMESERVER=true groovy:tcpdump

.PHONY: container
container:
	docker build -t groovy:tcpdump .

.PHONY: clean
clean:
	docker image rm groovy:tcpdump
