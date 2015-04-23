FROM ubuntu:12.04
MAINTAINER Nicolai Kochtov
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -yyyy install \
  mpich2 netcat-openbsd openssh-client openssh-server build-essential nano python-numpy nfs-common
#nfs-server linux-headers-$(uname -r) ssh
#openmpi-bin openmpi-common openssh-client openssh-server libopenmpi1.3 libopenmpi-dbg libopenmpi-dev\

# Add mpi user and ssh keys 
RUN useradd -d /home/mpiu -m mpiu && su mpiu -c "mkdir /home/mpiu/.ssh"
ADD id_rsa /home/mpiu/.ssh/
ADD id_rsa.pub /home/mpiu/.ssh/authorized_keys
RUN chown mpiu /home/mpiu/.ssh/id_rsa && chown mpiu /home/mpiu/.ssh/authorized_keys && \
    chgrp mpiu /home/mpiu/.ssh/id_rsa && chgrp mpiu /home/mpiu/.ssh/authorized_keys && \
    chmod 600  /home/mpiu/.ssh/id_rsa && chmod 600  /home/mpiu/.ssh/authorized_keys && \
    su mpiu -c "cp /home/mpiu/.ssh/authorized_keys /home/mpiu/.ssh/id_rsa.pub"

# Set up SSH
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i "s/Port 22/Port 2022/g" /etc/ssh/sshd_config && echo "Port 2022" >> /etc/ssh/ssh_config \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && echo "UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ADD mpi_hello.c /home/mpiu/mpi_hello.c

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ADD init.sh /
RUN chmod +x /init.sh

