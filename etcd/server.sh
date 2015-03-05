#!/bin/bash
mkdir /etc/etcd
echo $host
echo "addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
echo "bind_addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
etcd &
addr=$(etcdctl get /addr | grep -x  [0-9]*.[0-9]*.[0-9]*.[0-9]*)
while [ "${addr}" = "" ]
do
sleep 1s
addr=$(etcdctl get /addr | grep -x  [0-9]*.[0-9]*.[0-9]*.[0-9]*)
echo $addr
done
echo client addr $addr
echo hello | nc $addr 1027
echo sent hello

