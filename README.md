Test to see if a "java.net.ConnectException: HTTP connect timed out" exception
from Java's [HttpClient](https://docs.oracle.com/en/java/javase/21/docs/api/java.net.http/java/net/http/HttpClient.html)
is returned when there is a DNS failure.

## Short answer

It does confusingly return a "java.net.ConnectException: HTTP connect timed out" exception
in the case of a DNS timeout. Proof provided below with tcpdump output.

And there seems to be a 10s timeout for DNS???

## Usage

- `make break` -- make the HttpClient request fail by breaking DNS resolution
- `make work` -- let the HttpClient request succeed by leaving DNS resolution alone
- `make clean` -- remove the Docker image we create

## `make break` output

```
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
02:49:36.353649 IP 172.17.0.4.58328 > 99.99.99.99.53: 21058+ A? www.google.com. (32)
02:49:36.353681 IP 172.17.0.4.58328 > 99.99.99.99.53: 53056+ AAAA? www.google.com. (32)
02:49:41.359324 IP 172.17.0.4.58328 > 99.99.99.99.53: 21058+ A? www.google.com. (32)
02:49:41.359415 IP 172.17.0.4.58328 > 99.99.99.99.53: 53056+ AAAA? www.google.com. (32)
java.net.http.HttpConnectTimeoutException: HTTP connect timed out
	at java.net.http/jdk.internal.net.http.HttpClientImpl.send(HttpClientImpl.java:568)
	at java.net.http/jdk.internal.net.http.HttpClientFacade.send(HttpClientFacade.java:123)
	at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
	at script.run(script.groovy:10)
	at groovy.lang.GroovyShell.runScriptOrMainOrTestOrRunnable(GroovyShell.java:287)
Test to see if a "java.net.ConnectException: HTTP connect timed out" exception
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
took 10.136 seconds
```


## `make work` output

```
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
02:51:07.184790 IP 172.17.0.4.60860 > 192.168.65.7.53: 23138+ A? www.google.com. (32)
02:51:07.184832 IP 172.17.0.4.60860 > 192.168.65.7.53: 47203+ AAAA? www.google.com. (32)
02:51:07.186858 IP 192.168.65.7.53 > 172.17.0.4.60860: 47203 1/0/0 AAAA 2607:f8b0:4005:80c::2004 (74)
02:51:07.190326 IP 192.168.65.7.53 > 172.17.0.4.60860: 23138 1/0/0 A 142.250.189.228 (62)
02:51:07.204406 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [S], seq 193924719, win 65495, options [mss 65495,sackOK,TS val 2612942646 ecr 0,nop,wscale 7], length 0
02:51:07.219804 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [S.], seq 3655501291, ack 193924720, win 65408, options [mss 65495,nop,nop,TS val 480329665 ecr 2612942646,nop,wscale 7], length 0
02:51:07.219824 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [.], ack 1, win 512, options [nop,nop,TS val 2612942661 ecr 480329665], length 0
02:51:07.239647 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [P.], seq 1:482, ack 1, win 512, options [nop,nop,TS val 2612942681 ecr 480329665], length 481
02:51:07.239807 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [.], ack 482, win 507, options [nop,nop,TS val 480329685 ecr 2612942681], length 0
02:51:07.264736 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 1:4119, ack 482, win 4096, options [nop,nop,TS val 480329710 ecr 2612942681], length 4118
02:51:07.264749 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [.], ack 4119, win 480, options [nop,nop,TS val 2612942706 ecr 480329710], length 0
02:51:07.271935 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [P.], seq 482:488, ack 4119, win 480, options [nop,nop,TS val 2612942713 ecr 480329710], length 6
02:51:07.272169 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [.], ack 488, win 4095, options [nop,nop,TS val 480329717 ecr 2612942713], length 0
02:51:07.319719 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [P.], seq 488:578, ack 4119, win 480, options [nop,nop,TS val 2612942761 ecr 480329717], length 90
02:51:07.319974 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [P.], seq 578:744, ack 4119, win 480, options [nop,nop,TS val 2612942761 ecr 480329717], length 166
02:51:07.320682 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [.], ack 744, win 4093, options [nop,nop,TS val 480329766 ecr 2612942761], length 0
success! (GET https://www.google.com/) 200
took 0.313 seconds
02:51:07.335074 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 4119:4767, ack 744, win 4096, options [nop,nop,TS val 480329780 ecr 2612942761], length 648
02:51:07.335842 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 4767:4798, ack 744, win 4096, options [nop,nop,TS val 480329781 ecr 2612942761], length 31
02:51:07.336058 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [P.], seq 744:791, ack 4798, win 475, options [nop,nop,TS val 2612942778 ecr 480329780], length 47
02:51:07.336145 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [.], ack 791, win 4095, options [nop,nop,TS val 480329781 ecr 2612942778], length 0
02:51:07.392655 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 4798:15998, ack 791, win 4096, options [nop,nop,TS val 480329838 ecr 2612942778], length 11200
02:51:07.394440 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 15998:17398, ack 791, win 4096, options [nop,nop,TS val 480329840 ecr 2612942778], length 1400
02:51:07.394450 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [.], ack 17398, win 512, options [nop,nop,TS val 2612942836 ecr 480329838], length 0
02:51:07.394563 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 17398:18331, ack 791, win 4096, options [nop,nop,TS val 480329840 ecr 2612942778], length 933
02:51:07.394573 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 18331:21131, ack 791, win 4096, options [nop,nop,TS val 480329840 ecr 2612942778], length 2800
02:51:07.394893 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 21131:23931, ack 791, win 4096, options [nop,nop,TS val 480329840 ecr 2612942836], length 2800
02:51:07.394897 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [.], ack 23931, win 512, options [nop,nop,TS val 2612942836 ecr 480329840], length 0
02:51:07.396345 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [P.], seq 23931:26067, ack 791, win 4096, options [nop,nop,TS val 480329841 ecr 2612942836], length 2136
02:51:07.402101 IP 172.17.0.4.34432 > 142.250.189.228.443: Flags [P.], seq 791:846, ack 26067, win 512, options [nop,nop,TS val 2612942844 ecr 480329841], length 55
02:51:07.402252 IP 142.250.189.228.443 > 172.17.0.4.34432: Flags [.], ack 846, win 4095, options [nop,nop,TS val 480329847 ecr 2612942844], length 0
```
