#! /bin/bash
line="zookeeper.connect=localhost:2181"
rep="zookeeper.connect=${zookeeper}:2181"
sed -i "s/${line}/${rep}/g" /kafka_2.10-0.8.2.0/config/server.properties
cd /kafka_2.10-0.8.2.0
bin/kafka-server-start.sh config/server.properties > /dev/null &
bin/kafka-topics.sh --create --zookeeper $zookeeper:2181 --replication-factor 1 --partitions 1 --topic test
echo -e $host "\n" | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
echo sent host $host
echo $(nc -l 1027) received
