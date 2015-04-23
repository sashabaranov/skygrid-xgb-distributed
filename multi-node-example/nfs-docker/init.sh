#!/bin/bash
depmod -a
rpcbind
service nfs-kernel-server start
#service etcd start
/bin/bash
service nfs-kernel-server stop

