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

def handler(channel, method, header, body):
    print(body)
    channel.basic_ack(method.delivery_tag)

channel.basic_qos(prefetch_count=1)
channel.basic_consume(handler, queue='spam_test_queue')
channel.start_consuming()

