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

CMD /run.sh
