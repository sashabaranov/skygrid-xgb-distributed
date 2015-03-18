## Etcd

В контейнере скрипт для запуска клиентов.

### Запуск клиентов

Каждого из клиентов запускает строчка:
```
sudo docker run -t -i --rm=true --net=host -e "host=192.168.202.51" -e "client=$(ip addr show eth0 | sed -n 3p | cut -d ' ' -f 6 | cut -d '/' -f 1)" -e "xgboost_addr=127.0.0.1" -e "xgboost_port=1027" -e "clients_number=2" -e "task=myTask" kochetovnicolai/etcd-client  /etcd_client.sh`
```
Где 
* `host` - адрес сервера
* `client` - адрес, по которому клиент виден снаружи
* `xgboost_addr` и `xgboost_port`- адрес предполагаемого контейнера с xgboost. 
* `clients_number` - число запускаемых клиентов
* `task` - id задачи


