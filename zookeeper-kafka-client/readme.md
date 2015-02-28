## ZooKeaper + Kafka

[Kafka](http://kafka.apache.org/) - сервис поверх zookeeper для общения между узлами кластера.

Соответственно, предполагается, что где-то zookeeper слушает 2181-й порт. Например, можно поиспользовать готовый docker контейнер:

`docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 jplock/zookeeper`

### Как это запустить?

1. Построить Dockerfile: `sudo docker build -t kochetovnicolai/zookeeper-kafka-client .`. 
Наверное, залью на dockerhub, так как строится долго.
2. Запустить двумя способами:
      * `sudo docker run -t -i -e "host=127.0.0.1" -e "zookeeper=127.0.0.1" --net=host kochetovnicolai/zookeeper-kafka-client /producer.sh` 
      * `sudo docker run -t -i -e "host=127.0.0.1" -e "zookeeper=127.0.0.1" --net=host kochetovnicolai/zookeeper-kafka-client /consumer.sh`

   где `host` - адрес снаружи контейнера, `zookeeper` - адрес zookeeper

При удачном стечение обстоятельств producer перешлет consumer-у текст `hello`.
