#!/usr/bin/env bash

# Need to do this at runtime since Docker will setup resolv.conf itself, so we need to overwrite it
if [ -n "$FIRST_NAMESERVER" ]; then
    echo "nameserver $FIRST_NAMESERVER" > /etc/resolv.conf
fi

if [ -n "$SECOND_NAMESERVER" ]; then
    echo "nameserver $SECOND_NAMESERVER" >> /etc/resolv.conf
fi

if [ -n "$DNS_TIMEOUT" ]; then
    echo "options timeout:$DNS_TIMEOUT" >> /etc/resolv.conf
fi

if [ -n "$DEBUG" ]; then
    echo "========== BEGIN /etc/resolv.conf =========="
    cat /etc/resolv.conf
    echo "=========== END /etc/resolv.conf ==========="
    echo ""

    tcpdump -n port 53 or port 443 &
fi

if [ -n "$PATCH_MODULE" ]; then
    export JAVA_OPTS="--patch-module $PATCH_MODULE"
fi
/usr/bin/groovy script.groovy "$@"
