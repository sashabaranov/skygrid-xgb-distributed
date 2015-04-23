## Запуск mpi,rabit и xgboost на двух машинах

По очереди запускаются стандартные примеры, проверяющие работу mpi, rabit и xgboost

### Построение контейнеров
1. etcd: `sudo docker build -t kochetovnicolai/etcd-client ./etcd` (в ветке etcd-client)
2. nfs: `sudo docker build -t kochetovnicolai/nfs-server ./nfs-docker`
3. mpi и xgboot: `sudo docker build -t kochetovnicolai/mpi-node ./xgboost-docker`

### Запуск
все адреса порты (которые подаются на вход контейнерам) зашиты в скриптах start.sh, последовательно запускаем 
1. ./nfs-docker/start.sh на student01 (192.168.202.51)
2. ./xgboost-docker/start.sh на 2-х любых хостах

### Пример запуска
student03:
```
nikolay@student03:~/mpi$ ./start.sh 
[1]+ Running sudo docker run -t -i --rm=true --net=host --privileged -e "nfs_server=192.168.202.51" -e "nfs_port=7000" -e "host=${local_addr}" kochetovnicolai/mpi-node /init.sh &
1
sudo docker run -t -i --rm=true --net=host --privileged -e "nfs_server=192.168.202.51" -e "nfs_port=7000" -e "host=${local_addr}" kochetovnicolai/mpi-node /init.sh
192.168.202.66
connected to server
ttl is not defined, will use default value
using 3600 seconds for task 'myTask0'
{"action":"create","node":{"key":"/myTask0","dir":true,"expiration":"2015-04-23T21:58:04.662665095Z","ttl":3600,"modifiedIndex":1176,"createdIndex":1176}}
I'm the leader
I'm not the last. waiting
{"action":"set","node":{"key":"/myTask0/finished","value":"true","modifiedIndex":1179,"createdIndex":1179}}
ip 0 192.168.202.66
received host 0 192.168.202.66
sent
___ 0
ip 1 192.168.202.65
received host 1 192.168.202.65
sent
/tmp/hosts
192.168.202.66          ub0
192.168.202.65          ub1
finished 0-th
order humber 0
will start mpi example
Warning: Permanently added '[192.168.202.65]:2022' (ECDSA) to the list of known hosts.
Hello from processor 0 of 2
Hello from processor 1 of 2
will start rabit example
mpirun -n 5 --hostfile /mirror/nodes.conf wrapper/basic.py rabit_tracker_uri=192.168.202.66 rabit_tracker_port=9091
Warning: Permanently added '[192.168.202.65]:2022' (ECDSA) to the list of known hosts.
@tracker All of 5 nodes getting started
@tracker All nodes finishes job
@tracker 0.0217490196228 secs between node start and job finish
@node[0] before-allreduce: a=[ 0.  1.  2.]
@node[0] after-allreduce-max: a=[ 4.  5.  6.]
@node[0] after-allreduce-sum: a=[ 20.  25.  30.]
@node[1] before-allreduce: a=[ 1.  2.  3.]
@node[1] after-allreduce-max: a=[ 4.  5.  6.]
@node[1] after-allreduce-sum: a=[ 20.  25.  30.]
@node[4] before-allreduce: a=[ 4.  5.  6.]
@node[4] after-allreduce-max: a=[ 4.  5.  6.]
@node[4] after-allreduce-sum: a=[ 20.  25.  30.]
@node[3] before-allreduce: a=[ 3.  4.  5.]
@node[3] after-allreduce-max: a=[ 4.  5.  6.]
@node[3] after-allreduce-sum: a=[ 20.  25.  30.]
@node[2] before-allreduce: a=[ 2.  3.  4.]
@node[2] after-allreduce-max: a=[ 4.  5.  6.]
@node[2] after-allreduce-sum: a=[ 20.  25.  30.]
will start xgboost example
mpirun -n 5 --hostfile /mirror/nodes.conf ../../xgboost mushroom-col.conf dsplit=col rabit_tracker_uri=192.168.202.66 rabit_tracker_port=9091
Warning: Permanently added '[192.168.202.65]:2022' (ECDSA) to the list of known hosts.
start student02:1
start student03:2
start student02:0
@tracker All of 5 nodes getting started
start student03:3
start student03:4
[0]     test-error:0.016139     train-error:0.014433
[1]     test-error:0.000000     train-error:0.001228
6513x118 matrix with 30707 entries is loaded from train.col2
6513x126 matrix with 26608 entries is loaded from train.col0
1611x126 matrix with 35442 entries is loaded from ../../demo/data/agaricus.txt.test
boosting round 0, 0 sec elapsed
boosting round 1, 0 sec elapsed

updating end, 0 sec in all
6513x114 matrix with 27913 entries is loaded from train.col1
@tracker All nodes finishes job
@tracker 0.285927057266 secs between node start and job finish
6513x125 matrix with 27348 entries is loaded from train.col3
6513x122 matrix with 30710 entries is loaded from train.col4
booster[0]:
0:[odor=none] yes=1,no=2
        1:[spore-print-color=green] yes=3,no=4
                3:leaf=1.85965
                4:[stalk-surface-below-ring=scaly] yes=7,no=8
                        7:leaf=0.808511
                        8:leaf=-1.98531
        2:[stalk-root=club] yes=5,no=6
                5:[bruises?=bruises] yes=9,no=10
                        9:leaf=-1.98104
                        10:leaf=1.77778
                6:[stalk-root=rooted] yes=11,no=12
                        11:leaf=-1.95062
                        12:leaf=1.90175
booster[1]:
0:[odor=none] yes=1,no=2
        1:[spore-print-color=green] yes=3,no=4
                3:leaf=0.994744
                4:[gill-size=broad] yes=7,no=8
                        7:leaf=-1.15275
                        8:leaf=-0.0386054
        2:[bruises?=bruises] yes=5,no=6
                5:[gill-spacing=close] yes=9,no=10
                        9:leaf=-0.127376
                        10:leaf=-6.87558
                6:leaf=1.1457
root@student03:/# exit
```

student02:
```
nikolay@student02:~/mpi$ ./start.sh 
[1]+ Running sudo docker run -t -i --rm=true --net=host --privileged -e "nfs_server=192.168.202.51" -e "nfs_port=7000" -e "host=${local_addr}" kochetovnicolai/mpi-node /init.sh &
1
sudo docker run -t -i --rm=true --net=host --privileged -e "nfs_server=192.168.202.51" -e "nfs_port=7000" -e "host=${local_addr}" kochetovnicolai/mpi-node /init.sh
connected to server
ttl is not defined, will use default value
using 3600 seconds for task 'myTask0'
192.168.202.65
{"errorCode":105,"message":"Key already exists","cause":"/myTask0","index":1177}
I'm the 1-th
I'm the last
{"action":"set","node":{"key":"/myTask0/finished","value":"true","modifiedIndex":1179,"createdIndex":1179}}
ip 0 192.168.202.66
received host 0 192.168.202.66
sent
ip 1 192.168.202.65
sent
received host 1 192.168.202.65
___ 1
/tmp/hosts
192.168.202.66          ub0
192.168.202.65          ub1
deleted task 'myTask0' directory
finished 1-th
order humber 1
root@student02:/# exit
```
