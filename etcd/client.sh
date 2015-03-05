#!/bin/bash
mkdir /etc/etcd
echo "addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
echo "bind_addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
ans=$(etcdctl set /addr "${host}")
while [ "${ans}" != "${host}" ]
do
sleep 1s
ans=$(etcdctl set /addr $host)
done
echo "set key /addr" $addr
echo $(nc -l 1027) received

