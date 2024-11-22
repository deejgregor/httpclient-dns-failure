#!/usr/bin/env bash

# Need to do this at runtime since Docker will setup resolv.conf itself, so we need to overwrite it
if [ -z "$DO_NOT_BREAK" ]; then
    echo "nameserver 99.99.99.99" > /etc/resolv.conf
fi

tcpdump -n port 53 or port 443 &

# JAVA_HOME gets reset when the 'su - groovy' happens, so set it on the way in
su - groovy -c "JAVA_HOME=$JAVA_HOME groovy script.groovy"
