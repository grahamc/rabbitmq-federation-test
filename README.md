
```
docker build -t rabbit .
federate_reciprocal.py
./producer.sh $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rabbit_b) 6672
./consumer.sh $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rabbit_b) 7672
```
