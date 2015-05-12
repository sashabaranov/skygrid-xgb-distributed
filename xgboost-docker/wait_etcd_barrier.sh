#!/bin/bash
task=$1
ip=$2
port=$3
barrier=$4
number=$5

curl -L http://$ip:$port/v2/keys/$task/$barrier -XPUT -d dir=true -d prevExist=false >/dev/null

#something like leader election
for ((i=0; i<$number ; i++))
do
  ans=$(curl -L http://$ip:$port/v2/keys/$task/$barrier/$i?prevExist=false \
                                                         -XPUT -d value=$i 2>/dev/null)
  error=$(echo $ans | grep errorCode)
  if [ "${error}" == "" ]
  then
    my_number=$i
    break
  fi
done
echo $my_number
if (($my_number + 1 < $number)) 
then
  ./wait_etcd_key.py $task $ip $port $barrier/$barrier >/dev/null
else
  curl -L http://$ip:$port/v2/keys/$task/$barrier/$barrier -XPUT -d value=opened >/dev/null
fi
