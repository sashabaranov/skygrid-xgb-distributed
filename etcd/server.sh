#!/bin/bash
mkdir /etc/etcd
echo $host
echo "addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
echo "bind_addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
etcd &
http://$host:4001/v2/keys/hello -XPUT -d value=hello
curl -L http://$host:4001/v2/keys/addr$clientsNumber?wait=true
curl -L http://$host:4001/v2/keys/clientsNumber -XPUT -d value=$clientsNumber
for ((i=1; i<=$clientsNumber; i++))
do
  curl -L http://$host:4001/v2/keys/finished$i?wait=true
done
echo all finished
