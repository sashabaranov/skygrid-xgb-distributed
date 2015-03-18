#!/bin/bash

if [ "${task}" == "" ]
  then echo "please, set task name as '-e \"task=task_name\"'" ; exit; fi
if [ "${clients_number}" == "" ]
  then echo "please, set number of client as '-e \"clients_number=number_of_clients\"'" ; exit; fi
if [ "${host}" == "" ]
  then echo "please, set host ip as '-e \"host=host_ip\"'" ; exit; fi
if [ "${client}" == "" ]
  then echo "please, set client ip as '-e \"client=client_ip\"'" ; exit; fi
if [ "${xgboost_addr}" == "" ]
  then echo "please, set xgboost container ip as '-e \"xgboost_addr=xgboost_container_ip\"'" ; exit; fi
if [ "${xgboost_port}" == "" ]
  then echo "please, set xgboost conteiner port as '-e \"xgboost_port=xgboost_container_port\"'" ; exit; fi

#try to connect with server
#for ((; ;))
#do
  ans=$(curl -L http://$host:4001/v2/keys/hello 2>/dev/null)
  if [ "${ans}" != "" ]
  then
    echo "connected to server"
    #break
  else
    echo $ans
    echo "error: couldn't connet with etcd server, will try again"
    exit
    #sleep 1s
  fi
#done

#create temporary task directory
if [ "${ttl}" == "" ]
then
  echo "ttl is not defined, will use default value"
  ttl=3600
fi
echo "using ${ttl} seconds for task '${task}'"
curl -L http://$host:4001/v2/keys/$task -XPUT -d ttl=$ttl -d dir=true -d prevExist=false 2>/dev/null

#something like leader election
for ((i=0; i<$clients_number ; i++))
do
  ans=$(curl -L http://$host:4001/v2/keys/$task/addr$i?prevExist=false -XPUT -d value=$client 2>/dev/null)
  error=$(echo $ans | grep errorCode)
  if [ "${error}" == "" ]
  then
    my_number=$i
    break
  fi
done

if [ "${my_number}" == "" ]
  then echo "error: task '${task}' already have ${clients_number} clients. exiting."; exit
fi

if (( $my_number == 0 ))
  then echo "I'm the leader"
  else echo "I'm the ${my_number}-th"
fi

#synchronization
if (( $my_number + 1 == $clients_number ))
then
  echo "I'm the last"
  curl -L http://$host:4001/v2/keys/$task/finished -XPUT -d value=true
else
  echo "I'm not the last. waiting"
  curl -L "http://${host}:4001/v2/keys/${task}/finished?prevExist=false&wait=true"
fi

#send clients nubmer
echo $clients_number | nc $xgboost_addr $xgboost_port

# ok, let's read the list of ip adress
for ((i=0; i<$clients_number; i++))
do
  ans=$(curl -L http://$host:4001/v2/keys/$task/addr$i 2>/dev/null)
  #TODO: add normal json parsing
  ip=$(echo $ans | tr '[{}],' ' ' | cut -d ' ' -f 1- | tr ' ' '\n' | grep value | cut -d ':' -f 2 | cut -f 2 -d '"')
  echo ip $i $ip
  echo $ip | nc $xgboost_addr $xgboost_port
  echo sent
done

# removing task directory, or cleaner election
for ((i=0; i<$clients_number ; i++))
do
  ans=$(curl -L http://$host:4001/v2/keys/$task/finished$i?prevExist=false -XPUT -d value=$client 2>/dev/null)
  error=$(echo $ans | grep errorCode)
  if [ "${error}" == "" ]
  then
    finished_number=$i
    break
  fi
done

if (( $finished_number + 1 == $clients_number ))
then
  # the latter closes the door
  curl -L http://$host:4001/v2/keys/$task?recursive=true -XDELETE 2>/dev/null >/dev/null
  echo "deleted task '${task}' directory" 
fi

echo "finished ${finished_number}-th"

