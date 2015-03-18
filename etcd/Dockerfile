FROM ubuntu:14.04
MAINTAINER Nicolai Kochtov
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl
ADD etcd_client.sh /
RUN chmod +x /etcd_client.sh
