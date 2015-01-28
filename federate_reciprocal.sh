#!/bin/bash

set -e
set -u

export DIP=$(boot2docker ip)

function start {
  docker run -dit \
    -p $(($1 + 4369)):4369 \
    -p $(($1 + 5672)):5672 \
    -p $(($1 + 15672)):15672 \
    -p $(($1 + 25672)):25672 \
    --hostname rabbit_$2 \
    -e HOST_HOSTNAME=rabbit_$2 \
    -e RABBITMQ_USERNAME=user \
    -e RABBITMQ_PASSWORD=user \
    --name rabbit_$2 \
    rabbit

  echo "to watch logs, run: docker attach rabbit_$2"
  echo "admin page: http://$DIP:$(($1 + 15672))"
}

function start_servers {
  start 1000 a
  start 2000 b
}

function federate {
  curl -XPUT \
    -H "content-type:application/json" \
    -d '{ "value": {
          "uri": "amqp://user:user@'$3'",
          "max-hops": 1,
          "ack-mode": "on-publish",
          "exchange": "spam_test_exch",
        }}' \
    http://user:user@$DIP:$1/api/parameters/federation-upstream/%2f/$2

  curl -XPUT \
    -H "content-type:application/json" \
    -d '{ "pattern": "^spam_test_exch",
          "definition": {
            "federation-upstream-set": "all"
          },
          "apply-to":"exchanges"
        }' \
    http://user:user@$DIP:$1/api/policies/%2f/federate-me
}

start_servers

echo "Waiting 30 seconds for good measure"
sleep 30

#rabbit_a
federate 16672 rabbit_b $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rabbit_b)

#rabbit_b
federate 17672 rabbit_a $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rabbit_a)

echo "You can delete all yourboot2docker nodes with: docker ps -a | awk '{ print \$1}' | xargs docker rm -f"

