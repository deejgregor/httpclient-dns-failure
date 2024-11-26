#FROM groovy
#
#USER root
#
#RUN apt-get update && \
#    apt-get install -y tcpdump && \
#    rm -rf /var/lib/apt/lists/*

FROM oraclelinux:9

RUN yum install -y tcpdump java-21-openjdk
# RUN yum install -y java-21-jmods

COPY HttpClientTimeout.java /HttpClientTimeout.java

COPY run.sh /run.sh
RUN chmod 755 /run.sh

COPY java.net.http-patched-jdk-21+11.jar /java.net.http.jar

# Make the default DNS timeout significantly fater
ENV DNS_TIMEOUT=2

CMD ["/run.sh"]
