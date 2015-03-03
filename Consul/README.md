## Consul
###Использование

Собрать контейнер:
`docker build -t dananastasyev/docker-consul .`

Далее запустить первый сервер:

```docker run -t -i --name node1 -h node1 dananastasyev/docker-consul -server -bootstrap-expect 2 /producer.sh```

Узнать его адрес: 
`JOIN_IP="$(sudo docker inspect -f '{{.NetworkSettings.IPAddress}}' node1)"`

И запустить второй сервер, присоединив его к первому:

`docker run -t -i --name node2 -h node2 dananastasyev/docker-consul -server -join $JOIN_IP /consumer.sh`

Кажется, ничего не должно мешать им теперь пообщаться.
