#!/bin/bash

set -ue

source ./rabbit_config.sh

ifconfig

exec rabbitmq-server

