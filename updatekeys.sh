#!/bin/bash

rm -f /etc/ssh/ssh_known_hosts

for host in `cat /etc/ssh/shosts.equiv`
do 
    ssh-keyscan -t rsa $host >> /etc/ssh/ssh_known_hosts
    cp /etc/ssh/ssh_known_hosts /root/.ssh/known_hosts
done
