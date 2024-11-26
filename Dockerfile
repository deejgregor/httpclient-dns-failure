#FROM groovy
#
#USER root
#
#RUN apt-get update && \
#    apt-get install -y tcpdump && \
#    rm -rf /var/lib/apt/lists/*

FROM oraclelinux:9

RUN yum install -y tcpdump java-21-openjdk unzip
RUN cd /tmp && \
    curl -fLO https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-binary-4.0.12.zip && \
    unzip -d /usr/local /tmp/apache-groovy-binary-4.0.12.zip

# for groovy image
#COPY java.policy /home/groovy/.java.policy
#COPY script.groovy /home/groovy/script.groovy

# for oraclelinux:9
COPY script.groovy /script.groovy

COPY run.sh /run.sh
RUN chmod 755 /run.sh

# for groovy image
# COPY java.net.http-patched-jdk-17+11.jar /java.net.http.jar
# for oraclelinux:9 image
COPY java.net.http-patched-jdk-21+11.jar /java.net.http.jar

# Make the default DNS timeout significantly fater
ENV DNS_TIMEOUT=2

CMD ["/run.sh"]
