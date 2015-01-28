#!/bin/bash

set -ue

source ./rabbit_config.sh

exec rabbitmqctl -n "$RABBITMQ_NODENAME" $@

