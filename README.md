Test to see if a "java.net.ConnectException: HTTP connect timed out" exception
from Java's [HttpClient](https://docs.oracle.com/en/java/javase/21/docs/api/java.net.http/java/net/http/HttpClient.html)
is returned when there is a DNS failure.

## Short answer

It does confusingly return a "java.net.ConnectException: HTTP connect timed out" exception
in the case of a DNS timeout *when the DNS resolution takes longer than the HttpRequest timeout*
(see output for `no-dns-faster-timeout-connect`).

If the DNS resolution completes before the HttpRequest timeout, then the exception shows a root
cause of UnresolvedAddressException (see output for `no-dns-faster-timeout-dns`).

With [this patch to MultiExchange.java](multiexchange.patch), it will throw an
UnresolvedAddressException regardless of which timeout is longer (see output for
`no-dns-faster-timeout-connect-with-patch`).

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

- `./test.sh` -- run all tests, show summary output

## `./test.sh` output

```
sha256:3469cd26c347ee280ef4cb62307bbabae79959f1124b681b27d876d39938a958

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview
==> /etc/oracle-release <==
Oracle Linux Server release 9.5

==> /etc/os-release <==
NAME="Oracle Linux Server"

==> /etc/redhat-release <==
Red Hat Enterprise Linux release 9.5 (Plow)

==> /etc/system-release <==
Oracle Linux Server release 9.5
openjdk version "21.0.5" 2024-10-15 LTS
OpenJDK Runtime Environment (Red_Hat-21.0.5.0.11-1.0.1) (build 21.0.5+11-LTS)
OpenJDK 64-Bit Server VM (Red_Hat-21.0.5.0.11-1.0.1) (build 21.0.5+11-LTS, mixed mode, sharing)

========= REQUEST_TIMEOUT = PT3S, CONNECT_TIMEOUT = -, ASYNC = sync ========
                                    work: SUCCESS! Took 0.312 seconds: (GET https://www.google.com/) 200
                       work-on-dns-retry: SUCCESS! Took 1.342 seconds: (GET https://www.google.com/) 200
                         unreachable-url: FAILURE! Took 3.093 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
              unreachable-url-with-patch: FAILURE! Took 3.102 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
               no-dns-faster-timeout-dns: FAILURE! Took 2.116 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
    no-dns-faster-timeout-dns-with-patch: FAILURE! Took 2.139 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
           no-dns-faster-timeout-connect: FAILURE! Took 4.128 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
no-dns-faster-timeout-connect-with-patch: FAILURE! Took 4.136 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException

========= REQUEST_TIMEOUT = PT3S, CONNECT_TIMEOUT = -, ASYNC = async ========
                                    work: SUCCESS! Took 0.328 seconds: (GET https://www.google.com/) 200
                       work-on-dns-retry: SUCCESS! Took 1.344 seconds: (GET https://www.google.com/) 200
                         unreachable-url: FAILURE! Took 3.090 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
              unreachable-url-with-patch: FAILURE! Took 3.106 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
               no-dns-faster-timeout-dns: FAILURE! Took 2.133 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
    no-dns-faster-timeout-dns-with-patch: FAILURE! Took 2.144 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
           no-dns-faster-timeout-connect: FAILURE! Took 4.123 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
no-dns-faster-timeout-connect-with-patch: FAILURE! Took 4.139 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException

========= REQUEST_TIMEOUT = -, CONNECT_TIMEOUT = PT3S, ASYNC = sync ========
                                    work: SUCCESS! Took 0.319 seconds: (GET https://www.google.com/) 200
                       work-on-dns-retry: SUCCESS! Took 1.327 seconds: (GET https://www.google.com/) 200
                         unreachable-url: FAILURE! Took 3.099 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
              unreachable-url-with-patch: FAILURE! Took 3.112 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
               no-dns-faster-timeout-dns: FAILURE! Took 2.125 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
    no-dns-faster-timeout-dns-with-patch: FAILURE! Took 2.137 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
           no-dns-faster-timeout-connect: FAILURE! Took 4.116 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
no-dns-faster-timeout-connect-with-patch: FAILURE! Took 4.145 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException

========= REQUEST_TIMEOUT = -, CONNECT_TIMEOUT = PT3S, ASYNC = async ========
                                    work: SUCCESS! Took 0.306 seconds: (GET https://www.google.com/) 200
                       work-on-dns-retry: SUCCESS! Took 1.344 seconds: (GET https://www.google.com/) 200
                         unreachable-url: FAILURE! Took 3.104 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
              unreachable-url-with-patch: FAILURE! Took 3.115 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
               no-dns-faster-timeout-dns: FAILURE! Took 2.122 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
    no-dns-faster-timeout-dns-with-patch: FAILURE! Took 2.120 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
           no-dns-faster-timeout-connect: FAILURE! Took 4.135 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
no-dns-faster-timeout-connect-with-patch: FAILURE! Took 4.143 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
```

## `DEBUG=true ./test.sh no-dns-faster-timeout-dns`

```
sha256:3469cd26c347ee280ef4cb62307bbabae79959f1124b681b27d876d39938a958
Test case: no-dns-faster-timeout-dns
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:1
=========== END /etc/resolv.conf ===========

+ java /HttpClientTimeout.java sync https://www.google.com/ PT3S -
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
22:19:58.754371 IP 172.17.0.4.43914 > 192.0.2.1.domain: 15326+ A? www.google.com. (32)
22:19:58.754410 IP 172.17.0.4.43914 > 192.0.2.1.domain: 33247+ AAAA? www.google.com. (32)
22:19:59.756043 IP 172.17.0.4.43914 > 192.0.2.1.domain: 15326+ A? www.google.com. (32)
22:19:59.756127 IP 172.17.0.4.43914 > 192.0.2.1.domain: 33247+ AAAA? www.google.com. (32)
FAILURE! Took 2.113 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
java.net.ConnectException
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:951)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:133)
	at Main.main(HttpClientTimeout.java:53)
	at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)
	at java.base/java.lang.reflect.Method.invoke(Method.java:580)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.execute(Main.java:484)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.run(Main.java:208)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.main(Main.java:135)
Caused by: java.net.ConnectException
	at java.net.http/jdk.internal.net.http.common.Utils.toConnectException(Utils.java:1041)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:227)
	at java.net.http/jdk.internal.net.http.AsyncSSLConnection.connectAsync(AsyncSSLConnection.java:56)
	at java.net.http/jdk.internal.net.http.Http2Connection.createAsync(Http2Connection.java:527)
	at java.net.http/jdk.internal.net.http.Http2ClientImpl.getConnectionFor(Http2ClientImpl.java:138)
	at java.net.http/jdk.internal.net.http.ExchangeImpl.get(ExchangeImpl.java:94)
	at java.net.http/jdk.internal.net.http.Exchange.establishExchange(Exchange.java:391)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl0(Exchange.java:584)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl(Exchange.java:428)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsync(Exchange.java:420)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:413)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsyncImpl$7(MultiExchange.java:454)
	at java.base/java.util.concurrent.CompletableFuture.uniHandle(CompletableFuture.java:934)
	at java.base/java.util.concurrent.CompletableFuture.uniHandleStage(CompletableFuture.java:950)
	at java.base/java.util.concurrent.CompletableFuture.handle(CompletableFuture.java:2372)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:444)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsync0$2(MultiExchange.java:346)
	at java.base/java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:1150)
	at java.base/java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:510)
	at java.base/java.util.concurrent.CompletableFuture$AsyncSupply.run(CompletableFuture.java:1773)
	at java.net.http/jdk.internal.net.http.HttpClientImpl$DelegatingExecutor.execute(HttpClientImpl.java:177)
	at java.base/java.util.concurrent.CompletableFuture.completeAsync(CompletableFuture.java:2719)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsync(MultiExchange.java:299)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.sendAsync(HttpClientImpl.java:1049)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:930)
	... 7 more
Caused by: java.nio.channels.UnresolvedAddressException
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:137)
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:145)
	at java.base/sun.nio.ch.SocketChannelImpl.checkRemote(SocketChannelImpl.java:842)
	at java.base/sun.nio.ch.SocketChannelImpl.connect(SocketChannelImpl.java:865)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.lambda$connectAsync$1(PlainHttpConnection.java:210)
	at java.base/java.security.AccessController.doPrivileged(AccessController.java:571)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:212)
	... 30 more
+ '[' -n true ']'
+ set +x

4 packets captured
4 packets received by filter
0 packets dropped by kernel
```

## `DEBUG=true ./test.sh no-dns-faster-timeout-connect`

```
sha256:3469cd26c347ee280ef4cb62307bbabae79959f1124b681b27d876d39938a958
Test case: no-dns-faster-timeout-connect
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:2
=========== END /etc/resolv.conf ===========

+ java /HttpClientTimeout.java sync https://www.google.com/ PT3S -
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
22:20:13.697038 IP 172.17.0.4.57821 > 192.0.2.1.domain: 37665+ A? www.google.com. (32)
22:20:13.697071 IP 172.17.0.4.57821 > 192.0.2.1.domain: 49440+ AAAA? www.google.com. (32)
22:20:15.699663 IP 172.17.0.4.57821 > 192.0.2.1.domain: 37665+ A? www.google.com. (32)
22:20:15.699726 IP 172.17.0.4.57821 > 192.0.2.1.domain: 49440+ AAAA? www.google.com. (32)
FAILURE! Took 4.133 seconds: Root cause exception: java.net.ConnectException: HTTP connect timed out
java.net.http.HttpConnectTimeoutException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:945)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:133)
	at Main.main(HttpClientTimeout.java:53)
	at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)
	at java.base/java.lang.reflect.Method.invoke(Method.java:580)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.execute(Main.java:484)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.run(Main.java:208)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.main(Main.java:135)
Caused by: java.net.http.HttpConnectTimeoutException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.MultiExchange.toTimeoutException(MultiExchange.java:585)
	at java.net.http/jdk.internal.net.http.MultiExchange.getExceptionalCF(MultiExchange.java:532)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsyncImpl$7(MultiExchange.java:452)
	at java.base/java.util.concurrent.CompletableFuture.uniHandle(CompletableFuture.java:934)
	at java.base/java.util.concurrent.CompletableFuture.uniHandleStage(CompletableFuture.java:950)
	at java.base/java.util.concurrent.CompletableFuture.handle(CompletableFuture.java:2372)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:444)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsync0$2(MultiExchange.java:346)
	at java.base/java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:1150)
	at java.base/java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:510)
	at java.base/java.util.concurrent.CompletableFuture$AsyncSupply.run(CompletableFuture.java:1773)
	at java.net.http/jdk.internal.net.http.HttpClientImpl$DelegatingExecutor.execute(HttpClientImpl.java:177)
	at java.base/java.util.concurrent.CompletableFuture.completeAsync(CompletableFuture.java:2719)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsync(MultiExchange.java:299)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.sendAsync(HttpClientImpl.java:1049)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:930)
	... 7 more
Caused by: java.net.ConnectException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.MultiExchange.toTimeoutException(MultiExchange.java:586)
	... 22 more
+ '[' -n true ']'
+ set +x

4 packets captured
4 packets received by filter
0 packets dropped by kernel
```

## `DEBUG=true ./test.sh no-dns-faster-timeout-connect-with-patch`

```
sha256:3469cd26c347ee280ef4cb62307bbabae79959f1124b681b27d876d39938a958
Test case: no-dns-faster-timeout-connect-with-patch
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:2
=========== END /etc/resolv.conf ===========

+ java --patch-module java.net.http=/java.net.http.jar /HttpClientTimeout.java sync https://www.google.com/ PT3S -
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
22:20:26.024814 IP 172.17.0.4.49114 > 192.0.2.1.domain: 18945+ A? www.google.com. (32)
22:20:26.024858 IP 172.17.0.4.49114 > 192.0.2.1.domain: 34563+ AAAA? www.google.com. (32)
22:20:28.028187 IP 172.17.0.4.49114 > 192.0.2.1.domain: 18945+ A? www.google.com. (32)
22:20:28.028275 IP 172.17.0.4.49114 > 192.0.2.1.domain: 34563+ AAAA? www.google.com. (32)
FAILURE! Took 4.141 seconds: Root cause exception: java.nio.channels.UnresolvedAddressException
java.net.ConnectException
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:951)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:133)
	at Main.main(HttpClientTimeout.java:53)
	at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)
	at java.base/java.lang.reflect.Method.invoke(Method.java:580)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.execute(Main.java:484)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.run(Main.java:208)
	at jdk.compiler/com.sun.tools.javac.launcher.Main.main(Main.java:135)
Caused by: java.net.ConnectException
	at java.net.http/jdk.internal.net.http.common.Utils.toConnectException(Utils.java:1041)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:227)
	at java.net.http/jdk.internal.net.http.AsyncSSLConnection.connectAsync(AsyncSSLConnection.java:56)
	at java.net.http/jdk.internal.net.http.Http2Connection.createAsync(Http2Connection.java:527)
	at java.net.http/jdk.internal.net.http.Http2ClientImpl.getConnectionFor(Http2ClientImpl.java:138)
	at java.net.http/jdk.internal.net.http.ExchangeImpl.get(ExchangeImpl.java:94)
	at java.net.http/jdk.internal.net.http.Exchange.establishExchange(Exchange.java:391)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl0(Exchange.java:584)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsyncImpl(Exchange.java:428)
	at java.net.http/jdk.internal.net.http.Exchange.responseAsync(Exchange.java:420)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsyncImpl(MultiExchange.java:409)
	at java.net.http/jdk.internal.net.http.MultiExchange.lambda$responseAsync0$2(MultiExchange.java:342)
	at java.base/java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:1150)
	at java.base/java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:510)
	at java.base/java.util.concurrent.CompletableFuture$AsyncSupply.run(CompletableFuture.java:1773)
	at java.net.http/jdk.internal.net.http.HttpClientImpl$DelegatingExecutor.execute(HttpClientImpl.java:177)
	at java.base/java.util.concurrent.CompletableFuture.completeAsync(CompletableFuture.java:2719)
	at java.net.http/jdk.internal.net.http.MultiExchange.responseAsync(MultiExchange.java:295)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.sendAsync(HttpClientImpl.java:1049)
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:930)
	... 7 more
Caused by: java.nio.channels.UnresolvedAddressException
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:137)
	at java.base/sun.nio.ch.Net.checkAddress(Net.java:145)
	at java.base/sun.nio.ch.SocketChannelImpl.checkRemote(SocketChannelImpl.java:842)
	at java.base/sun.nio.ch.SocketChannelImpl.connect(SocketChannelImpl.java:865)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.lambda$connectAsync$1(PlainHttpConnection.java:210)
	at java.base/java.security.AccessController.doPrivileged(AccessController.java:571)
	at java.net.http/jdk.internal.net.http.PlainHttpConnection.connectAsync(PlainHttpConnection.java:212)
	... 25 more
+ '[' -n true ']'
+ set +x

4 packets captured
4 packets received by filter
0 packets dropped by kernel
```
