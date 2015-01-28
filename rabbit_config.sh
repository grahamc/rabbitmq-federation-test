#!/bin/bash

set -ue

readonly COOKIE_FILE="/var/lib/rabbitmq/.erlang.cookie"

function expand_resources {
  ulimit -n 1024
}

function persist_cookie {
  local COOKIE="$1"

  echo "Persisting cookie to $COOKIE_FILE"
  echo "$COOKIE" > $COOKIE_FILE
  chmod 400 $COOKIE_FILE
  chown rabbitmq:rabbitmq $COOKIE_FILE
}

function override_identity {
  export RABBITMQ_NODENAME="rabbit@$HOST_HOSTNAME"
}

function dev_credentials {
  set +u
  if [ ! -z "$RABBITMQ_USERNAME" ]; then
    if [ ! -z "$RABBITMQ_PASSWORD" ]; then
      set -u

      echo "Overriding user and password for development"
      cat > /etc/rabbitmq/rabbitmq.config <<EOF
[
  {rabbit, [{default_user, <<"$RABBITMQ_USERNAME">>},{default_pass, <<"$RABBITMQ_PASSWORD">>},{tcp_listeners, [{"0.0.0.0", 5672}]}]}
].
EOF
    fi
  fi

  set -u
}

expand_resources
persist_cookie "$COOKIE"
override_identity
dev_credentials

