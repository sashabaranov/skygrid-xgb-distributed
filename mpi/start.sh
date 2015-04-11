set -m
local_addr=$(ip addr show eth0 | sed -n 3p | cut -d ' ' -f 6 | cut -d '/' -f 1)
sudo docker run -t -i --rm=true --net=host --privileged -e "host=${local_addr}" \
       kochetovnicolai/mpi-node /init.sh &
task=$(jobs | grep 'kochetovnicolai/mpi-node /init.sh')
echo $task
task=$(echo $task | cut -d ' ' -f 1 | cut -d '[' -f 2 | cut -d ']' -f 1)
echo $task
$(sudo docker run -t -i --rm=true --net=host -e "host=192.168.202.51" \
    -e "client=${local_addr}" \
    -e "xgboost_addr=127.0.0.1" -e "xgboost_port=1027" -e "clients_number=2" \
    -e "task=myTask0" kochetovnicolai/etcd-client  /etcd_client.sh)  &
fg $task
