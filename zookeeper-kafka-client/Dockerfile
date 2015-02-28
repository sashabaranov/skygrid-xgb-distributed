FROM ubuntu:14.04
MAINTAINER Nicolai Kochtov
EXPOSE 1027
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget default-jre
RUN wget http://apache-mirror.rbc.ru/pub/apache/kafka/0.8.2.0/kafka_2.10-0.8.2.0.tgz && tar -xzf kafka_2.10-0.8.2.0.tgz
ADD consumer.sh /
ADD producer.sh /
RUN chmod +x producer.sh consumer.sh
