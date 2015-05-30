#!/bin/bash

if [ "${task}" == "" ]
  then echo "please, set task name as '-e \"task=task_name\"'" ; exit; fi
if [ "${clients_number}" == "" ]
  then echo "please, set number of client as '-e \"clients_number=number_of_clients\"'" ; exit; fi
if [ "${host_ip}" == "" ]
  then echo "please, set host ip as '-e \"host_ip=host_ip\"'" ; exit; fi
if [ "${etcd_ip}" == "" ]
  then echo "please, set etcd server ip as '-e \"etcd_ip=client_ip\"'" ; exit; fi
if [ "${etcd_port}" == "" ]
  then echo "please, set etcd server port as '-e \"etcd_port=etcd_port\"'" ; exit; fi
if [ "${nfs_ip}" == "" ]
  then echo "please, set nfs container ip as '-e \"nfs_ip=nfs_ip\"'" ; exit; fi
if [ "${nfs_port}" == "" ]
  then echo "please, set nfs conteiner port as '-e \"nfs_port=xgboost_container_port\"'" ; exit; fi
if [ "${xgboost_config}" == "" ]
  then echo "please, set xgboost config file as '-e \"xgboost_config=config_file\"'" ; exit; fi
if [ "${ttl}" == "" ]
then
  echo "ttl is not defined, will use default value"
  ttl=360
fi
echo "using ${ttl} seconds for task '${task}'"
curl -L http://$etcd_ip:$etcd_port/v2/keys/$task -XPUT -d ttl=$ttl -d dir=true -d prevExist=false 2>/dev/null

order_number=$(./wait_etcd_barrier.sh $task $etcd_ip $etcd_port leader_election $clients_number)
echo "I'm the ${order_number}-th"
curl -L http://$etcd_ip:$etcd_port/v2/keys/$task/ip -XPUT -d dir=true -d prevExist=false 2>/dev/null
curl -L http://$etcd_ip:$etcd_port/v2/keys/$task/ip/$order_number -XPUT -d value=$host_ip 2>/dev/null
./wait_etcd_barrier.sh $task $etcd_ip $etcd_port ip_exchange $clients_number

for ((i=0; i<$clients_number; i++))
do
  response=$(curl -L http://$etcd_ip:$etcd_port/v2/keys/$task/ip/$i 2>/dev/null)
  next_ip=$(echo $response | tr '[{}],' ' ' | cut -d ' ' -f 1- | tr ' ' '\n' | grep value | cut -d ':' -f 2 | cut -f 2 -d '"')
  echo "received ip ${i} ${next_ip}"
  echo "${next_ip}" >> /home/mpiu/machinefile
done

/usr/sbin/sshd -D &
mkdir /mirror
chown mpiu /mirror
chown mpiu /data
mount -t nfs -o proto=tcp,port=$nfs_port $nfs_ip:/mirror /mirror

./wait_etcd_barrier.sh $task $etcd_ip $etcd_port ssh $clients_number

if (($order_number == 0))
then
  su mpiu -c "mpicc ~/mpi_hello.c -o ~/mpi_hello"
  echo mpicc
  su mpiu -c "cp ~/mpi_hello /mirror/mpi_hello"
  echo cp1
  su mpiu -c "cp ~/machinefile /mirror/nodes.conf"
  echo cp2
  echo 'will start mpi example'
  su mpiu -c "mpiexec -f /mirror/nodes.conf /mirror/mpi_hello"

  echo 'will start rabit example'
  su mpiu -c "cd /mirror/xgboost/subtree/rabit \
                && ./tracker/rabit_mpi.py -n 5 -H /mirror/nodes.conf wrapper/basic.py"
  echo 'will start xgboost example'
  su mpiu -c "cd /mirror/xgboost/multi-node/col-split \
                && rm -rf train.col* *.model \
                && python splitsvm.py ../../demo/data/agaricus.txt.train train 5 \
                && ../../subtree/rabit/tracker/rabit_mpi.py -n 5 -H /mirror/nodes.conf \
                        ../../xgboost mushroom-col.conf dsplit=col \
                && ../../xgboost mushroom-col.conf task=dump model_in=0002.model \
                        fmap=../../demo/data/featmap.txt name_dump=dump.nice.5.txt \
                && cat dump.nice.5.txt"
  echo 'will start traning'
  rm -r /mirror/${task}
  su mpiu -c "mkdir /mirror/${task} \
              && cd /mirror/${task} \
              && ../xgboost/subtree/rabit/tracker/rabit_mpi.py -n ${clients_number} \
                   -H /mirror/nodes.conf ../xgboost/xgboost /data/${xgboost_config} dsplit=col"
fi

./wait_etcd_barrier.sh $task $etcd_ip $etcd_port training $clients_number
echo 'will start test'
model=$(ls -1 /mirror/$task | grep .model | tail -n 1)
echo model $model
su mpiu -c "cd /mirror/${task} \
            && ../xgboost/xgboost /data/${xgboost_config} task=pred model_in=${model} \
			name_pred=/data/${clients_number}.txt"
./wait_etcd_barrier.sh $task $etcd_ip $etcd_port testing $clients_number
#/bin/bash

exit_number=$(./wait_etcd_barrier.sh $task $etcd_ip $etcd_port cleaner $clients_number)
if (($exit_number + 1 == $clients_number))
then
  curl -L http://$etcd_ip:$etcd_port/v2/keys/$task?recursive=true -XDELETE 2>/dev/null >/dev/null
  echo "deleted task '${task}' directory"
fi

