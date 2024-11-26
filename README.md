Test to see if a "java.net.ConnectException: HTTP connect timed out" exception
from Java's [HttpClient](https://docs.oracle.com/en/java/javase/21/docs/api/java.net.http/java/net/http/HttpClient.html)
is returned when there is a DNS failure.

## Short answer

It does confusingly return a "java.net.ConnectException: HTTP connect timed out" exception
in the case of a DNS timeout *when the DNS resolution takes longer than the HttpRequest timeout*
(see output for `break-faster-timeout-connect`).

If the DNS resolution completes before the HttpRequest timeout, then the exception shows a root
cause of UnresolvedAddressException (see output for `break-faster-timeout-dns`).

With [this patch to MultiExchange.java](multiexchange.patch), it will throw an
UnresolvedAddressException regardless of which timeout is longer (see output for
`break-faster-timeout-connect-with-patch`).

By default, when there is a DNS problem, the request blocks for a fixed timeout when using the system's DNS resolver of 10 seconds, and this appears to be due to
the defualt resolver timeout (`RES_TIMEOUT`) of 5 seconds for 2 attempts (`RES_DFLRETRY`):

```
              timeout:n
                     Sets the amount of time the resolver will wait for
                     a response from a remote name server before
                     retrying the query via a different name server.
                     This may not be the total time taken by any
                     resolver API call and there is no guarantee that a
                     single resolver API call maps to a single timeout.
                     Measured in seconds, the default is RES_TIMEOUT
                     (currently 5, see <resolv.h>).  The value for this
                     option is silently capped to 30.

              attempts:n
                     Sets the number of times the resolver will send a
                     query to its name servers before giving up and
                     returning an error to the calling application.  The
                     default is RES_DFLRETRY (currently 2, see
                     <resolv.h>).  The value for this option is silently
                     capped to 5.
```

(source: [Linux resolv.conf man page](https://man7.org/linux/man-pages/man5/resolv.conf.5.html))

For testing failures, this sets a timeout of 1 second to speed up the process except for the `make break` case.

## Usage

- `make all` -- run all tests, show summary output
- `make help` -- list all targets
- `make clean` -- remove the Docker image we create

## `make all` output

```
docker build -q -t groovy:tcpdump .
sha256:49aff5ad14a04255cfba65003eacc988eaa6eee0fe3cf921fe7f7bdb01112af4
docker run -it --rm groovy:tcpdump java -version
openjdk version "17.0.13" 2024-10-15
OpenJDK Runtime Environment Temurin-17.0.13+11 (build 17.0.13+11)
OpenJDK 64-Bit Server VM Temurin-17.0.13+11 (build 17.0.13+11, mixed mode, sharing)
work: SUCCESS! Took 0.283 seconds. (GET https://www.google.com/) 200
work-on-dns-retry: SUCCESS! Took 1.324 seconds. (GET https://www.google.com/) 200
unreachable-url: FAILURE! Took 3.104 seconds. Root cause exception: java.net.ConnectException: HTTP connect timed out
unreachable-url-with-patch: FAILURE! Took 3.098 seconds. Root cause exception: java.net.ConnectException: HTTP connect timed out
break-faster-timeout-dns: FAILURE! Took 2.134 seconds. Root cause exception: java.nio.channels.UnresolvedAddressException
break-faster-timeout-connect: FAILURE! Took 4.121 seconds. Root cause exception: java.net.ConnectException: HTTP connect timed out
break-faster-timeout-connect-with-patch: FAILURE! Took 4.127 seconds. Root cause exception: java.nio.channels.UnresolvedAddressException
```

## `make DOCKER_BUILD=-q DEBUG=true break-faster-timeout-dns`

```
docker build -q -t groovy:tcpdump .
sha256:49aff5ad14a04255cfba65003eacc988eaa6eee0fe3cf921fe7f7bdb01112af4
docker run -it --rm -e DEBUG=true -e FIRST_NAMESERVER=192.0.2.1  -e DNS_TIMEOUT=1 groovy:tcpdump /run.sh https://www.google.com/
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:1
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
04:43:30.010337 IP 172.17.0.4.38176 > 192.0.2.1.53: 21914+ A? www.google.com. (32)
04:43:30.010382 IP 172.17.0.4.38176 > 192.0.2.1.53: 921+ AAAA? www.google.com. (32)
04:43:31.010795 IP 172.17.0.4.38176 > 192.0.2.1.53: 21914+ A? www.google.com. (32)
04:43:31.010998 IP 172.17.0.4.38176 > 192.0.2.1.53: 921+ AAAA? www.google.com. (32)
FAILURE! Took 2.127 seconds. Root cause exception: java.nio.channels.UnresolvedAddressException
java.net.ConnectException
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:574)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:123)
	at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
	at script.run(script.groovy:16)
	at groovy.lang.GroovyShell.runScriptOrMainOrTestOrRunnable(GroovyShell.java:287)
	at groovy.lang.GroovyShell.run(GroovyShell.java:393)
	at groovy.lang.GroovyShell.run(GroovyShell.java:382)
	at groovy.ui.GroovyMain.processOnce(GroovyMain.java:649)
	at groovy.ui.GroovyMain.run(GroovyMain.java:389)
	at groovy.ui.GroovyMain.access$1400(GroovyMain.java:67)
	at groovy.ui.GroovyMain$GroovyCommand.process(GroovyMain.java:313)
	at groovy.ui.GroovyMain.processArgs(GroovyMain.java:141)
	at groovy.ui.GroovyMain.main(GroovyMain.java:114)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:569)
	at org.codehaus.groovy.tools.GroovyStarter.rootLoader(GroovyStarter.java:115)
	at org.codehaus.groovy.tools.GroovyStarter.main(GroovyStarter.java:37)
Caused by: java.net.ConnectException
	at java.net.http/jdk.internal.net.http.common.Utils.toConnectException(Utils.java:1083)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:198)
	at java.net.http/jdk.internal.net.http.AsyncSSLConnection.connectAsync(AsyncSSLConnection.java:56)
	at java.net.http/jdk.internal.net.http.Http2Connection.createAsync(Http2Connection.java:443)
	at java.net.http/jdk.internal.net.http.Http2ClientImpl.getConnectionFor(Http2ClientImpl.java:131)
	at java.net.http/jdk.internal.net.http.ExchangeImpl.get(ExchangeImpl.java:93)
	at java.net.http/jdk.internal.net.http.Exchange.establishExchange(Exchange.java:349)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl0(Exchange.java:542)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl(Exchange.java:386)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsync(Exchange.java:378)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:408)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsyncImpl$7(MultiExchange.java:449)
	at java.base/java.util.concurrent.CompletableFuture.uniHandle(CompletableFuture.java:934)
	at java.base/java.util.concurrent.CompletableFuture.uniHandleStage(CompletableFuture.java:950)
	at java.base/java.util.concurrent.CompletableFuture.handle(CompletableFuture.java:2340)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:439)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsync0$2(MultiExchange.java:341)
	at java.base/java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:1150)
	at java.base/java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:510)
	at java.base/java.util.concurrent.CompletableFuture$AsyncSupply.run(CompletableFuture.java:1773)
	at java.net.http/jdk.internal.net.http.HttpClientImpl$DelegatingExecutor.execute(HttpClientImpl.java:158)
	at java.base/java.util.concurrent.CompletableFuture.completeAsync(CompletableFuture.java:2673)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsync(MultiExchange.java:294)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.sendAsync(HttpClientImpl.java:659)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:553)
	... 18 more
Caused by: java.nio.channels.UnresolvedAddressException
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:149)
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:157)
	at java.base/sun.nio.ch.SocketChannelImpl.checkRemote(SocketChannelImpl.java:816)
	at java.base/sun.nio.ch.SocketChannelImpl.connect(SocketChannelImpl.java:839)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.lambda$connectAsync$0(PlainHttpConnection.java:183)
	at java.base/java.security.AccessController.doPrivileged(AccessController.java:569)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:185)
	... 41 more
```

## `make DOCKER_BUILD=-q DEBUG=true break-faster-timeout-connect`

```
docker build -q -t groovy:tcpdump .
sha256:49aff5ad14a04255cfba65003eacc988eaa6eee0fe3cf921fe7f7bdb01112af4
docker run -it --rm -e DEBUG=true -e FIRST_NAMESERVER=192.0.2.1  groovy:tcpdump /run.sh https://www.google.com/
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:2
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
04:44:19.621909 IP 172.17.0.4.54460 > 192.0.2.1.53: 36488+ A? www.google.com. (32)
04:44:19.621949 IP 172.17.0.4.54460 > 192.0.2.1.53: 29321+ AAAA? www.google.com. (32)
04:44:21.625777 IP 172.17.0.4.54460 > 192.0.2.1.53: 36488+ A? www.google.com. (32)
04:44:21.625947 IP 172.17.0.4.54460 > 192.0.2.1.53: 29321+ AAAA? www.google.com. (32)
FAILURE! Took 4.137 seconds. Root cause exception: java.net.ConnectException: HTTP connect timed out
java.net.http.HttpConnectTimeoutException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:568)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:123)
	at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
	at script.run(script.groovy:16)
	at groovy.lang.GroovyShell.runScriptOrMainOrTestOrRunnable(GroovyShell.java:287)
	at groovy.lang.GroovyShell.run(GroovyShell.java:393)
	at groovy.lang.GroovyShell.run(GroovyShell.java:382)
	at groovy.ui.GroovyMain.processOnce(GroovyMain.java:649)
	at groovy.ui.GroovyMain.run(GroovyMain.java:389)
	at groovy.ui.GroovyMain.access$1400(GroovyMain.java:67)
	at groovy.ui.GroovyMain$GroovyCommand.process(GroovyMain.java:313)
	at groovy.ui.GroovyMain.processArgs(GroovyMain.java:141)
	at groovy.ui.GroovyMain.main(GroovyMain.java:114)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:569)
	at org.codehaus.groovy.tools.GroovyStarter.rootLoader(GroovyStarter.java:115)
	at org.codehaus.groovy.tools.GroovyStarter.main(GroovyStarter.java:37)
Caused by: java.net.http.HttpConnectTimeoutException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.MultiExchange.toTimeoutException(MultiExchange.java:580)
	at java.net.http/jdk.internal.net.http.MultiExchange.getExceptionalCF(MultiExchange.java:527)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsyncImpl$7(MultiExchange.java:447)
	at java.base/java.util.concurrent.CompletableFuture.uniHandle(CompletableFuture.java:934)
	at java.base/java.util.concurrent.CompletableFuture.uniHandleStage(CompletableFuture.java:950)
	at java.base/java.util.concurrent.CompletableFuture.handle(CompletableFuture.java:2340)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:439)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsync0$2(MultiExchange.java:341)
	at java.base/java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:1150)
	at java.base/java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:510)
	at java.base/java.util.concurrent.CompletableFuture$AsyncSupply.run(CompletableFuture.java:1773)
	at java.net.http/jdk.internal.net.http.HttpClientImpl$DelegatingExecutor.execute(HttpClientImpl.java:158)
	at java.base/java.util.concurrent.CompletableFuture.completeAsync(CompletableFuture.java:2673)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsync(MultiExchange.java:294)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.sendAsync(HttpClientImpl.java:659)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:553)
	... 18 more
Caused by: java.net.ConnectException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.MultiExchange.toTimeoutException(MultiExchange.java:581)
	... 33 more
```

## `make DOCKER_BUILD=-q DEBUG=true break-faster-timeout-connect-with-patch`

```
docker build -q -t groovy:tcpdump .
sha256:49aff5ad14a04255cfba65003eacc988eaa6eee0fe3cf921fe7f7bdb01112af4
docker run -it --rm -e DEBUG=true -e FIRST_NAMESERVER=192.0.2.1  -e PATCH_MODULE=java.net.http=/java.net.http.jar groovy:tcpdump /run.sh https://www.google.com/
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:2
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.vector, jdk.incubator.foreign
04:44:42.746514 IP 172.17.0.4.48626 > 192.0.2.1.53: 26114+ A? www.google.com. (32)
04:44:42.746553 IP 172.17.0.4.48626 > 192.0.2.1.53: 37377+ AAAA? www.google.com. (32)
04:44:44.746948 IP 172.17.0.4.48626 > 192.0.2.1.53: 26114+ A? www.google.com. (32)
04:44:44.746989 IP 172.17.0.4.48626 > 192.0.2.1.53: 37377+ AAAA? www.google.com. (32)
FAILURE! Took 4.132 seconds. Root cause exception: java.nio.channels.UnresolvedAddressException
java.net.ConnectException
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:574)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:123)
	at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
	at script.run(script.groovy:16)
	at groovy.lang.GroovyShell.runScriptOrMainOrTestOrRunnable(GroovyShell.java:287)
	at groovy.lang.GroovyShell.run(GroovyShell.java:393)
	at groovy.lang.GroovyShell.run(GroovyShell.java:382)
	at groovy.ui.GroovyMain.processOnce(GroovyMain.java:649)
	at groovy.ui.GroovyMain.run(GroovyMain.java:389)
	at groovy.ui.GroovyMain.access$1400(GroovyMain.java:67)
	at groovy.ui.GroovyMain$GroovyCommand.process(GroovyMain.java:313)
	at groovy.ui.GroovyMain.processArgs(GroovyMain.java:141)
	at groovy.ui.GroovyMain.main(GroovyMain.java:114)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:569)
	at org.codehaus.groovy.tools.GroovyStarter.rootLoader(GroovyStarter.java:115)
	at org.codehaus.groovy.tools.GroovyStarter.main(GroovyStarter.java:37)
Caused by: java.net.ConnectException
	at java.net.http/jdk.internal.net.http.common.Utils.toConnectException(Utils.java:1083)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:198)
	at java.net.http/jdk.internal.net.http.AsyncSSLConnection.connectAsync(AsyncSSLConnection.java:56)
	at java.net.http/jdk.internal.net.http.Http2Connection.createAsync(Http2Connection.java:443)
	at java.net.http/jdk.internal.net.http.Http2ClientImpl.getConnectionFor(Http2ClientImpl.java:131)
	at java.net.http/jdk.internal.net.http.ExchangeImpl.get(ExchangeImpl.java:93)
	at java.net.http/jdk.internal.net.http.Exchange.establishExchange(Exchange.java:349)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl0(Exchange.java:542)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl(Exchange.java:386)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsync(Exchange.java:378)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:407)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsync0$2(MultiExchange.java:340)
	at java.base/java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:1150)
	at java.base/java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:510)
	at java.base/java.util.concurrent.CompletableFuture$AsyncSupply.run(CompletableFuture.java:1773)
	at java.net.http/jdk.internal.net.http.HttpClientImpl$DelegatingExecutor.execute(HttpClientImpl.java:158)
	at java.base/java.util.concurrent.CompletableFuture.completeAsync(CompletableFuture.java:2673)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsync(MultiExchange.java:293)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.sendAsync(HttpClientImpl.java:659)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:553)
	... 18 more
Caused by: java.nio.channels.UnresolvedAddressException
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:149)
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:157)
	at java.base/sun.nio.ch.SocketChannelImpl.checkRemote(SocketChannelImpl.java:816)
	at java.base/sun.nio.ch.SocketChannelImpl.connect(SocketChannelImpl.java:839)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.lambda$connectAsync$0(PlainHttpConnection.java:183)
	at java.base/java.security.AccessController.doPrivileged(AccessController.java:569)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:185)
	... 36 more
```
