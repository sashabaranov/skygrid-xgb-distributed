#!/bin/bash
mkdir /etc/etcd
echo "addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf
echo "bind_addr = \"${host}:4001\"" >> /etc/etcd/etcd.conf

for ((; ;))
do
  ans=$(curl -L --retry 100 --retry-delay 1 http://$host:4001/v2/keys/hello)
  if [ "${ans}" != "" ]
  then
    break
  fi
  sleep 1s
done

for ((i=1;  ; i++))
do
  ans=$(curl -L http://$host:4001/v2/keys/addr$i?prevExist=false -XPUT -d value=$client)
  error=$(echo $ans | grep errorCode)
  if [ "${error}" == "" ]
  then
    myNumber=$i
    break
  fi
done

ans=$(curl -L http://$host:4001/v2/keys/clientsNumber?wait=true)
clientsNumber=$(echo $ans | tr '[{}],' ' ' | cut -d ' ' -f 1- | tr ' ' '\n' | grep value | cut -d ':' -f 2 | cut -f 2 -d '"')
echo clientsNumber $clientsNumber
echo $clientsNumber | nc $xgboost_addr $xgboost_port

for ((i=1; i<=$clientsNumber; i++))
do
  ans=$(curl -L http://$host:4001/v2/keys/addr$i)
  ip=$(echo $ans | tr '[{}],' ' ' | cut -d ' ' -f 1- | tr ' ' '\n' | grep value | cut -d ':' -f 2 | cut -f 2 -d '"')
  echo ip $i $ip
  echo $ip | nc $xgboost_addr $xgboost_port
  echo sent
done

curl -L http://$host:4001/v2/keys/finished$myNumber -XPUT -d value=1
echo finished $myNumber
