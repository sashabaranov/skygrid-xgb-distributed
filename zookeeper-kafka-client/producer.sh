#!/bin/bash
line="zookeeper.connect=localhost:2181"
rep="zookeeper.connect=${zookeeper}:2181"
sed -i "s/${line}/${rep}/g" /kafka_2.10-0.8.2.0/config/server.properties
cd /kafka_2.10-0.8.2.0
bin/kafka-server-start.sh config/server.properties > /dev/null &
bin/kafka-topics.sh --create --zookeeper $zookeeper:2181 --replication-factor 1 --partitions 1 --topic test
producer=$(bin/kafka-console-consumer.sh --zookeeper $zookeeper:2181 --topic test --from-beginning 2> /dev/null | head -n 1)
echo will send to $producer
echo hello | nc $producer 1027
echo sent hello
