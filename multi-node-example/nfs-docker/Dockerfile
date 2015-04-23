FROM ubuntu:12.04
MAINTAINER Nicolai Kochtov
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -yyyy install \
  nfs-server linux-headers-$(uname -r) nano git curl build-essential

#etcd
#RUN curl -L https://github.com/coreos/etcd/releases/download/v2.0.10/etcd-v2.0.10-linux-amd64.tar.gz \
#  -o /tmp/etcd-v2.0.10-linux-amd64.tar.gz \
#  && cd /tmp \
#  && tar xzvf /tmp/etcd-v2.0.10-linux-amd64.tar.gz \
#  && cp /tmp/etcd-v2.0.10-linux-amd64/etcd /bin/etcd
#COPY etcd.conf /etc/init/etcd.conf
#VOLUME /data

#nfs
RUN useradd -d /home/mpiu -m mpiu \
  && mkdir /mirror \
  && chown mpiu /mirror \
  && chgrp mpiu /mirror \
  && echo "/mirror *(rw,sync,no_subtree_check)" >> /etc/exports

EXPOSE 2049

#xgboost
RUN su mpiu -c " \
  cd /mirror \
  && git clone https://github.com/dmlc/xgboost.git \
  && cd xgboost \
  && bash build.sh \
  && cd subtree/rabit \
  && make \
  && cp guide/basic.py wrapper/basic.py \
  && chmod 777 -R /mirror \
"

COPY init.sh /
RUN chmod +x /init.sh
CMD /init.sh
