FROM groovy

USER root

RUN apt-get update && \
    apt-get install -y tcpdump && \
    rm -rf /var/lib/apt/lists/*

#USER groovy

COPY java.policy /home/groovy/.java.policy
COPY script.groovy /home/groovy/script.groovy
COPY run.sh /run.sh
RUN chmod 755 /run.sh

COPY java.net.http-patched-jdk-17+11.jar /java.net.http.jar

# Make the default DNS timeout significantly fater
ENV DNS_TIMEOUT=2

CMD ["/run.sh"]
