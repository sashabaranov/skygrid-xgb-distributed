#!/bin/bash

echo $host

# create temporary hosts file in /temp directory
hosts_number=$(nc -l localhost 1027)

for ((i=0; i<$hosts_number; i++))
do
  next_host=$(nc -l localhost 1027)
  echo "received host ${i} ${next_host}"
  echo "${next_host}		ub${i}" >> /tmp/hosts
  echo "${next_host}" >> /home/mpiu/machinefile
  if [ "${host}" == "${next_host}" ]
    then order_number=$i; echo ___ $i; fi
  if (($i == 0))
    then leader_addr=$next_host; fi
done
#cat /etc/hosts >> /tmp/hosts

echo "/tmp/hosts"
cat /tmp/hosts

# this is a hack using because of you can't change /etc/hosts in docker under 1.2 version
# there could be only one command 'mv /tmp/hosts /etc/hosts'
# or may be 'chattr -i /etc/hosts && mv /tmp/hosts /etc/hosts'
# see also http://unix.stackexchange.com/questions/57459/how-can-i-override-the-etc-hosts-file-at-user-level
mkdir -p -- /lib-override
cp /lib/x86_64-linux-gnu/libnss_files.so.2 /lib-override
perl -pi -e 's:/etc/hosts:/tmp/hosts:g' /lib-override/libnss_files.so.2
export LD_LIBRARY_PATH=/lib-override

#/etc/init.d/ssh start
mkdir /mirror
chown mpiu /mirror

echo "order humber ${order_number}"
if (($order_number == 0))
then
  echo "/mirror *(rw,sync,no_subtree_check)" | tee -a /etc/exports
  rpcbind
  service nfs-kernel-server start

  #su mpiu -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
  #su mpiu -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"

  su mpiu -c "cp ~/mpi_hello.c /mirror/mpi_hello.c"
  su mpiu -c "mpicc /mirror/mpi_hello.c -o /mirror/mpi_hello"
  su mpiu -c "cp ~/machinefile /mirror/machinefile"

  #test, no properly sync
  sleep 1
  echo 'hello' | nc ub1 1028
  echo sent to ub1
  sleep 1
  echo 'will start mpi example'
  su mpiu -c "mpiexec -f /mirror/machinefile /mirror/mpi_hello"
else
  echo received $(nc -l 1028)
  mount $leader_addr:/mirror /mirror
fi

/usr/sbin/sshd -D &
/bin/bash

if (($order_number == 0))
  then service nfs-kernel-server stop; fi
