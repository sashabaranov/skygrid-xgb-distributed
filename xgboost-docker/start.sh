local_addr=$(ip addr show eth0 | sed -n 3p | cut -d ' ' -f 6 | cut -d '/' -f 1)
sudo docker run -t -i --rm=true --net=host --privileged -v $(pwd)/data:/data \
    -e "xgboost_config=otto.conf" \
    -e "etcd_ip=192.168.202.51" \
    -e "etcd_port=4001" \
    -e "host_ip=${local_addr}" \
    -e "nfs_ip=192.168.202.51" \
    -e "nfs_port=7002" \
    -e "clients_number=2" \
    -e "task=myTask0" kochetovnicolai/multinode-xgboost /init.sh
