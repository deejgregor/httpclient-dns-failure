#!/usr/bin/env bash

REACHABLE_URL=${REACHABLE_URL:-https://www.google.com/}
REACHABLE_SECOND_NAMESERVER=${REACHABLE_SECOND_NAMESERVER:-8.8.8.8}

# TEST-NET RFC3330
UNREACHABLE_URL=${UNREACHABLE_URL:-https://192.0.2.1/}
UNREACHABLE_FIRST_NAMESERVER=${UNREACHABLE_FIRST_NAMESERVER:-192.0.2.1}

DEBUG=${DEBUG:-} # set to "true" to see debugging details

DOCKER_IMAGE=${DOCKER_IMAGE:-httpclient-dns-failure}

function run_test() {
    local testcase=$1; shift

    if [ -n "${DEBUG}" ]; then
        echo "Test case: $testcase"
    else
        printf "%40s: " "$testcase"
    fi

    # Allocate a tty so that tcpdump output isn't buffered
    eval docker run -t --rm -e DEBUG="${DEBUG}" -e ASYNC="${ASYNC}" -e REQUEST_TIMEOUT="${REQUEST_TIMEOUT}" -e CONNECT_TIMEOUT="${CONNECT_TIMEOUT}" "$@" "${DOCKER_IMAGE}"
    if [ $? -ne 0 ]; then
        exit
    fi
}

docker build -q -t "${DOCKER_IMAGE}" .

if [ $# -gt 0 ]; then
    ASYNC=sync
    REQUEST_TIMEOUT=PT3S
    CONNECT_TIMEOUT=-

    run_test $(grep "^$1 " testcases.txt)
    exit
fi

docker run --rm "${DOCKER_IMAGE}" sh -c "head -1 /etc/*release"
docker run --rm "${DOCKER_IMAGE}" java -version

for timeouts in "PT3S -" "- PT3S"; do
    read REQUEST_TIMEOUT CONNECT_TIMEOUT <<<"${timeouts}"
    for ASYNC in sync async; do

        echo ""
        echo "========= REQUEST_TIMEOUT = ${REQUEST_TIMEOUT}, CONNECT_TIMEOUT = ${CONNECT_TIMEOUT}, ASYNC = $ASYNC ========"
        cat testcases.txt | while read testcase args; do
            run_test "${testcase}" ${args}
        done
    done
done
