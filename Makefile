REACHABLE_URL=https://www.google.com/
REACHABLE_SECOND_NAMESERVER=8.8.8.8

UNREACHABLE_URL=https://192.0.2.1/
UNREACHABLE_FIRST_NAMESERVER=192.0.2.1 # 192.0.2.1 -- TEST-NET RFC3330

DEBUG="" # set to a non-empty string to see debugging details

DOCKER_BUILD= # set to -q to be quiet

.PHONY: help
help:
	@echo "Usage:" >&2
	@echo "    make all -- run all tests" >&2
	@echo "    make java-version -- show 'java -version'" >&2
	@echo "    make work -- let the HttpClient request succeed by leaving DNS resolution alone" >&2
	@echo "    make work-on-dns-retry -- make the HttpClient request succeed when querying a second DNS server" >&2
	@echo "    make unreachable-url -- make the HttpClient request fail by requesting an unreachable URL" >&2
	@echo "    make unreachable-url-with-patch -- make the HttpClient request fail by requesting an unreachable URL with patch" >&2
	@echo "    make break-faster-timeout-dns -- make the HttpClient request fail by breaking DNS resolution with DNS timeout < HttpRequest timeout" >&2
	@echo "    make break-faster-timeout-connect -- make the HttpClient request fail by breaking DNS resolution with DNS timeout > HttpRequest timeout" >&2
	@echo "    make break-faster-timeout-dns-with-patch -- make the HttpClient request fail by breaking DNS resolution with DNS timeout < HttpRequest timeout and the patch applied" >&2
	@echo "    make break-faster-timeout-connect-with-patch -- make the HttpClient request fail by breaking DNS resolution with DNS timeout < HttpRequest timeout and the patch applied" >&2
	@echo "    make clean -- remove the Docker image we create" >&2

.PHONY: all
all:
	@$(MAKE) DOCKER_BUILD=-q java-version
	@for target in work work-on-dns-retry unreachable-url unreachable-url-with-patch break-faster-timeout-dns break-faster-timeout-dns-with-patch break-faster-timeout-connect break-faster-timeout-connect-with-patch; do \
	    /bin/echo -n "$$target: "; $(MAKE) DOCKER_BUILD=-q $$target | tail -1; \
	done

.PHONY: java-version
java-version: container
	docker run -it --rm groovy:tcpdump java -version

.PHONY: work
work: container
	docker run -it --rm groovy:tcpdump /run.sh $(REACHABLE_URL)

.PHONY: work-on-dns-retry
work-on-dns-retry: container
	docker run -it --rm -e DEBUG=$(DEBUG) -e FIRST_NAMESERVER=$(UNREACHABLE_FIRST_NAMESERVER) -e DNS_TIMEOUT=1 -e SECOND_NAMESERVER=$(REACHABLE_SECOND_NAMESERVER) groovy:tcpdump /run.sh $(REACHABLE_URL)

.PHONY: unreachable-url
unreachable-url: container
	docker run -it --rm -e DEBUG=$(DEBUG) groovy:tcpdump /run.sh $(UNREACHABLE_URL)

.PHONY: unreachable-url-with-patch
unreachable-url-with-patch: container
	docker run -it --rm -e DEBUG=$(DEBUG) -e PATCH_MODULE=java.net.http=/java.net.http.jar groovy:tcpdump /run.sh $(UNREACHABLE_URL)

.PHONY: break-faster-timeout-dns
break-faster-timeout-dns: container
	docker run -it --rm -e DEBUG=$(DEBUG) -e FIRST_NAMESERVER=$(UNREACHABLE_FIRST_NAMESERVER) -e DNS_TIMEOUT=1 groovy:tcpdump /run.sh $(REACHABLE_URL)

.PHONY: break-faster-timeout-dns-with-patch
break-faster-timeout-dns-with-patch: container
	docker run -it --rm -e DEBUG=$(DEBUG) -e FIRST_NAMESERVER=$(UNREACHABLE_FIRST_NAMESERVER) -e DNS_TIMEOUT=1 -e PATCH_MODULE=java.net.http=/java.net.http.jar groovy:tcpdump /run.sh $(REACHABLE_URL)

.PHONY: break-faster-timeout-connect
break-faster-timeout-connect: container
	docker run -it --rm -e DEBUG=$(DEBUG) -e FIRST_NAMESERVER=$(UNREACHABLE_FIRST_NAMESERVER) groovy:tcpdump /run.sh $(REACHABLE_URL)

.PHONY: break-faster-timeout-connect-with-patch
break-faster-timeout-connect-with-patch: container
	docker run -it --rm -e DEBUG=$(DEBUG) -e FIRST_NAMESERVER=$(UNREACHABLE_FIRST_NAMESERVER) -e PATCH_MODULE=java.net.http=/java.net.http.jar groovy:tcpdump /run.sh $(REACHABLE_URL)

.PHONY: container
container:
	docker build $(DOCKER_BUILD) -t groovy:tcpdump .

.PHONY: clean
clean:
	docker image rm groovy:tcpdump
