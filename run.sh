#!/usr/bin/env bash

# Need to do this at runtime since Docker will setup resolv.conf itself, so we need to overwrite it
if [ -n "$BREAK" ]; then
    echo "nameserver 192.0.2.1" > /etc/resolv.conf # TEST-NET RFC3330
fi

if [ -n "$SECOND_NAMESERVER" ]; then
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi

if [ -n "$FAST_TIMEOUT" ]; then
    echo "options timeout:1" >> /etc/resolv.conf
fi

echo "========== BEGIN /etc/resolv.conf =========="
cat /etc/resolv.conf
echo "=========== END /etc/resolv.conf ==========="
echo ""

tcpdump -n port 53 or port 443 &

# JAVA_HOME gets reset when the 'su - groovy' happens, so set it on the way in
su - groovy -c "JAVA_HOME=$JAVA_HOME groovy script.groovy"
