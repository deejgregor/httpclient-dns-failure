Test to see if a "java.net.ConnectException: HTTP connect timed out" exception
from Java's [HttpClient](https://docs.oracle.com/en/java/javase/21/docs/api/java.net.http/java/net/http/HttpClient.html)
is returned when there is a DNS failure.

## Short answer

It does confusingly return a "java.net.ConnectException: HTTP connect timed out" exception
in the case of a DNS timeout *when the DNS resolution takes longer than the HttpRequest timeout*
(see output for `make break`).
If the DNS resolution completes before the HttpRequest timeout, then the exception shows a root
cause of UnresolvedAddressException (see output for `make break-fast-timeout`).

By default, when there is a DNS problem, the request blocks for a fixed timeout when using the system's DNS resolver of 10 seconds, and this appears to be due to:

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

For testing, this sets a timeout of 1 second to speed up the process.

## Usage

- `make work` -- let the HttpClient request succeed by leaving DNS resolution alone
- `make break` -- make the HttpClient request fail by breaking DNS resolution with DNS timeout > HttpRequest timeout
- `make break-fast-timeout` -- make the HttpClient request fail by breaking DNS resolution with DNS timeout < HttpRequest timeout
- `make work-on-retry` -- make the HttpClient request succeed when querying a second DNS server
- `make clean` -- remove the Docker image we create

## `make break` output

```
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.vector, jdk.incubator.foreign
03:50:34.909335 IP 172.17.0.4.48542 > 192.0.2.1.53: 7062+ A? www.google.com. (32)
03:50:34.909375 IP 172.17.0.4.48542 > 192.0.2.1.53: 31637+ AAAA? www.google.com. (32)
03:50:39.913981 IP 172.17.0.4.48542 > 192.0.2.1.53: 7062+ A? www.google.com. (32)
03:50:39.914215 IP 172.17.0.4.48542 > 192.0.2.1.53: 31637+ AAAA? www.google.com. (32)
java.net.http.HttpConnectTimeoutException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:568)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:123)
	at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
	at script.run(script.groovy:11)
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
took 10.143 seconds
```

## `make break-fast-timeout` output

```
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
options timeout:1
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
03:52:10.464650 IP 172.17.0.4.52911 > 192.0.2.1.53: 59178+ A? www.google.com. (32)
03:52:10.464693 IP 172.17.0.4.52911 > 192.0.2.1.53: 57387+ AAAA? www.google.com. (32)
03:52:11.466628 IP 172.17.0.4.52911 > 192.0.2.1.53: 59178+ A? www.google.com. (32)
03:52:11.466760 IP 172.17.0.4.52911 > 192.0.2.1.53: 57387+ AAAA? www.google.com. (32)
java.net.ConnectException
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:574)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:123)
	at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
	at script.run(script.groovy:11)
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
took 2.141 seconds
```

## `make work` output

```
========== BEGIN /etc/resolv.conf ==========
# Generated by Docker Engine.
# This file can be edited; Docker Engine will not make further changes once it
# has been modified.

nameserver 192.168.65.7

# Based on host file: '/etc/resolv.conf' (legacy)
# Overrides: []
options timeout:1
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.vector, jdk.incubator.foreign
03:39:24.955037 IP 172.17.0.4.33459 > 192.168.65.7.53: 1507+ A? www.google.com. (32)
03:39:24.955064 IP 172.17.0.4.33459 > 192.168.65.7.53: 59105+ AAAA? www.google.com. (32)
03:39:24.957475 IP 192.168.65.7.53 > 172.17.0.4.33459: 59105 1/0/0 AAAA 2607:f8b0:4005:814::2004 (74)
03:39:24.959550 IP 192.168.65.7.53 > 172.17.0.4.33459: 1507 1/0/0 A 142.250.191.68 (62)
03:39:24.972284 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [S], seq 2894845854, win 65495, options [mss 65495,sackOK,TS val 2494195293 ecr 0,nop,wscale 7], length 0
03:39:24.986894 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [S.], seq 345883783, ack 2894845855, win 65408, options [mss 65495,nop,nop,TS val 2962777969 ecr 2494195293,nop,wscale 7], length 0
03:39:24.986908 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [.], ack 1, win 512, options [nop,nop,TS val 2494195308 ecr 2962777969], length 0
03:39:25.008651 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [P.], seq 1:482, ack 1, win 512, options [nop,nop,TS val 2494195330 ecr 2962777969], length 481
03:39:25.008838 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [.], ack 482, win 507, options [nop,nop,TS val 2962777991 ecr 2494195330], length 0
03:39:25.030887 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 1:4119, ack 482, win 4096, options [nop,nop,TS val 2962778013 ecr 2494195330], length 4118
03:39:25.030896 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [.], ack 4119, win 480, options [nop,nop,TS val 2494195352 ecr 2962778013], length 0
03:39:25.036477 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [P.], seq 482:488, ack 4119, win 480, options [nop,nop,TS val 2494195358 ecr 2962778013], length 6
03:39:25.036607 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [.], ack 488, win 4095, options [nop,nop,TS val 2962778018 ecr 2494195358], length 0
success! (GET https://www.google.com/) 200
03:39:25.079759 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [P.], seq 488:578, ack 4119, win 480, options [nop,nop,TS val 2494195401 ecr 2962778018], length 90
03:39:25.079929 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [.], ack 578, win 4095, options [nop,nop,TS val 2962778062 ecr 2494195401], length 0
03:39:25.080020 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [P.], seq 578:744, ack 4119, win 480, options [nop,nop,TS val 2494195401 ecr 2962778062], length 166
03:39:25.080104 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [.], ack 744, win 4093, options [nop,nop,TS val 2962778062 ecr 2494195401], length 0
03:39:25.089665 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 4119:4767, ack 744, win 4096, options [nop,nop,TS val 2962778072 ecr 2494195401], length 648
03:39:25.090918 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 4767:4798, ack 744, win 4096, options [nop,nop,TS val 2962778073 ecr 2494195401], length 31
03:39:25.091468 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [P.], seq 744:791, ack 4798, win 475, options [nop,nop,TS val 2494195413 ecr 2962778072], length 47
03:39:25.091596 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [.], ack 791, win 4095, options [nop,nop,TS val 2962778073 ecr 2494195413], length 0
03:39:25.138594 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 4798:7598, ack 791, win 4096, options [nop,nop,TS val 2962778120 ecr 2494195413], length 2800
03:39:25.140045 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 7598:18214, ack 791, win 4096, options [nop,nop,TS val 2962778122 ecr 2494195413], length 10616
03:39:25.140052 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [.], ack 18214, win 512, options [nop,nop,TS val 2494195461 ecr 2962778120], length 0
03:39:25.141016 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 18214:23814, ack 791, win 4096, options [nop,nop,TS val 2962778123 ecr 2494195461], length 5600
03:39:25.141206 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [P.], seq 23814:26096, ack 791, win 4096, options [nop,nop,TS val 2962778123 ecr 2494195461], length 2282
03:39:25.143327 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [.], ack 26096, win 512, options [nop,nop,TS val 2494195464 ecr 2962778123], length 0
03:39:25.147017 IP 172.17.0.4.47270 > 142.250.191.68.443: Flags [P.], seq 791:846, ack 26096, win 512, options [nop,nop,TS val 2494195468 ecr 2962778123], length 55
03:39:25.147170 IP 142.250.191.68.443 > 172.17.0.4.47270: Flags [.], ack 846, win 4095, options [nop,nop,TS val 2962778129 ecr 2494195468], length 0
took 0.289 seconds
```

## `make work-on-retry` output

```
========== BEGIN /etc/resolv.conf ==========
nameserver 192.0.2.1
nameserver 8.8.8.8
options timeout:1
=========== END /etc/resolv.conf ===========

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
03:40:59.772109 IP 172.17.0.4.55231 > 192.0.2.1.53: 32436+ A? www.google.com. (32)
03:40:59.772143 IP 172.17.0.4.55231 > 192.0.2.1.53: 44213+ AAAA? www.google.com. (32)
03:41:00.772824 IP 172.17.0.4.56307 > 8.8.8.8.53: 32436+ A? www.google.com. (32)
03:41:00.772876 IP 172.17.0.4.56307 > 8.8.8.8.53: 44213+ AAAA? www.google.com. (32)
03:41:00.792317 IP 8.8.8.8.53 > 172.17.0.4.56307: 32436 1/0/0 A 142.250.189.228 (48)
03:41:00.793454 IP 8.8.8.8.53 > 172.17.0.4.56307: 44213 1/0/0 AAAA 2607:f8b0:4005:810::2004 (60)
03:41:00.820576 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [S], seq 3454917253, win 65495, options [mss 65495,sackOK,TS val 2615911562 ecr 0,nop,wscale 7], length 0
03:41:00.837899 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [S.], seq 1132677752, ack 3454917254, win 65408, options [mss 65495,nop,nop,TS val 483298583 ecr 2615911562,nop,wscale 7], length 0
03:41:00.837919 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 1, win 512, options [nop,nop,TS val 2615911579 ecr 483298583], length 0
03:41:00.863795 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [P.], seq 1:482, ack 1, win 512, options [nop,nop,TS val 2615911605 ecr 483298583], length 481
03:41:00.863988 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [.], ack 482, win 507, options [nop,nop,TS val 483298609 ecr 2615911605], length 0
03:41:00.886924 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 1:4120, ack 482, win 4096, options [nop,nop,TS val 483298632 ecr 2615911605], length 4119
03:41:00.886933 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 4120, win 480, options [nop,nop,TS val 2615911628 ecr 483298632], length 0
03:41:00.892839 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [P.], seq 482:488, ack 4120, win 480, options [nop,nop,TS val 2615911634 ecr 483298632], length 6
03:41:00.892967 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [.], ack 488, win 4095, options [nop,nop,TS val 483298638 ecr 2615911634], length 0
03:41:00.934044 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [P.], seq 488:578, ack 4120, win 480, options [nop,nop,TS val 2615911675 ecr 483298638], length 90
03:41:00.934227 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [.], ack 578, win 4095, options [nop,nop,TS val 483298679 ecr 2615911675], length 0
03:41:00.934311 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [P.], seq 578:744, ack 4120, win 480, options [nop,nop,TS val 2615911676 ecr 483298679], length 166
03:41:00.934465 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [.], ack 744, win 4093, options [nop,nop,TS val 483298679 ecr 2615911676], length 0
03:41:00.947625 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 4120:4768, ack 744, win 4096, options [nop,nop,TS val 483298693 ecr 2615911676], length 648
03:41:00.948820 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [P.], seq 744:791, ack 4768, win 475, options [nop,nop,TS val 2615911690 ecr 483298693], length 47
03:41:00.948940 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [.], ack 791, win 4095, options [nop,nop,TS val 483298694 ecr 2615911690], length 0
03:41:00.949310 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 4768:4799, ack 791, win 4096, options [nop,nop,TS val 483298694 ecr 2615911690], length 31
03:41:00.989514 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 4799, win 475, options [nop,nop,TS val 2615911731 ecr 483298694], length 0
success! (GET https://www.google.com/) 200
took 1.348 seconds
03:41:00.996942 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 4799:13199, ack 791, win 4096, options [nop,nop,TS val 483298742 ecr 2615911731], length 8400
03:41:00.996951 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 13199, win 512, options [nop,nop,TS val 2615911738 ecr 483298742], length 0
03:41:00.997916 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 13199:18546, ack 791, win 4096, options [nop,nop,TS val 483298743 ecr 2615911738], length 5347
03:41:00.997934 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 18546, win 512, options [nop,nop,TS val 2615911739 ecr 483298743], length 0
03:41:00.998546 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 18546:19946, ack 791, win 4096, options [nop,nop,TS val 483298743 ecr 2615911739], length 1400
03:41:00.998552 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 19946, win 512, options [nop,nop,TS val 2615911740 ecr 483298743], length 0
03:41:00.999755 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 19946:24146, ack 791, win 4096, options [nop,nop,TS val 483298745 ecr 2615911740], length 4200
03:41:00.999759 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 24146, win 512, options [nop,nop,TS val 2615911741 ecr 483298745], length 0
03:41:01.000447 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [P.], seq 24146:26097, ack 791, win 4096, options [nop,nop,TS val 483298745 ecr 2615911741], length 1951
03:41:01.000450 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [.], ack 26097, win 508, options [nop,nop,TS val 2615911742 ecr 483298745], length 0
03:41:01.006189 IP 172.17.0.4.54738 > 142.250.189.228.443: Flags [P.], seq 791:846, ack 26097, win 512, options [nop,nop,TS val 2615911747 ecr 483298745], length 55
03:41:01.006315 IP 142.250.189.228.443 > 172.17.0.4.54738: Flags [.], ack 846, win 4095, options [nop,nop,TS val 483298751 ecr 2615911747], length 0
```
