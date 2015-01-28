FROM ubuntu

RUN groupadd -g 9007 rabbitmq \
  && useradd --system \
     --uid 9007 \
     --gid rabbitmq \
     --shell /bin/false \
     --home-dir /var/lib/rabbitmq \
     rabbitmq

ADD http://www.rabbitmq.com/rabbitmq-signing-key-public.asc /tmp/key.asc
RUN apt-key add /tmp/key.asc \
  && echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq-debian.list \
  && apt-get update \
  && apt-get install -y rabbitmq-server \
  && rabbitmq-plugins enable rabbitmq_management \
  && rabbitmq-plugins enable rabbitmq_federation \
  && rabbitmq-plugins enable rabbitmq_federation_management


# The cookie must be identical across the cluster. A node with a non-matching
# cookie will not be permittd to join the cluster.
ENV COOKIE example

# Erlang Port Mapping Daemon (epmd). node <--> node communication
EXPOSE 4369

# Primary Rabbit port. node <--> node and node <--> client communication
EXPOSE 5672

# Rabbit Management plugin's web and HTTP API, node <--> administrative
EXPOSE 15672

# Rabbit's Clustering port, node <--> node communication
EXPOSE 25672

VOLUME /var/log/rabbitmq

ADD rabbit_config.sh /rabbit_config.sh
ADD run.sh /start
ADD rabbitctl.sh /rabbitctl
USER root:root
CMD ["/start"]

