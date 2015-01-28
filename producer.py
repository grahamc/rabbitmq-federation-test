#!/usr/bin/env python
import pika, json, sys

creds = pika.PlainCredentials('user', 'user')
conn_params = pika.ConnectionParameters(
        sys.argv[1],
        port=int(sys.argv[2]),
        virtual_host='/',
        credentials=pika.PlainCredentials('user', 'user'))
broker = pika.BlockingConnection(conn_params)

channel = broker.channel()
channel.exchange_declare(
        exchange='spam_test_exch',
        type='topic',
        auto_delete=False,
        durable=True
    )
channel.queue_declare(
        queue='spam_test_queue',
        auto_delete=False
    )
channel.queue_bind(
        queue='spam_test_queue',
        exchange='spam_test_exch',
        routing_key='spam_test'
    )

print("Starting up")
props = pika.BasicProperties(content_type="application/json")

for i in range(0, 10):
    channel.basic_publish(
            body="Hi #%d from %s" % (i, sys.argv[2]),
            exchange='spam_test_exch',
            routing_key='spam_test',
            properties=props
        )

