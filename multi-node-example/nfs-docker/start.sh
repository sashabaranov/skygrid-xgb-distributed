#!/bin/bash
sudo docker run -t -i -p 7004:2049  --privileged=true --rm=true   kochetovnicolai/nfs-etcd-server

