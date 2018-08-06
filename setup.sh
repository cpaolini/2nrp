#!/bin/bash

apt-get --quiet update; 
apt-get --quiet -y install screen emacs git python mlocate openmpi-bin openmpi-doc libopenmpi-dev make valgrind g++ m4 gfortran liblapacke-dev libnetcdf-dev iputils-ping openssh-server cmake mesa-utils-extra

if [ ! -f /etc/hosts.DIST ]
then
    cp /etc/hosts /etc/hosts.DIST
fi

if ! id subflow >/dev/null 2>&1
then
    groupadd subflow; useradd -g subflow -d /home/subflow -m -c 'Subflow Execution' -s /bin/bash subflow
fi

if [ ! -f /root/.ssh/id_rsa.pub ]
then
    echo -e 'y\n'|/usr/bin/ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
fi

c=`grep -c "HostbasedAuthentication yes" /etc/ssh/ssh_config`
if [ "$c" -eq "0" ]
then
    echo "Enable SSH client HostbasedAuthentication"
    echo "HostbasedAuthentication yes" >> /etc/ssh/ssh_config
fi
c=`grep -c "HostbasedAuthentication yes" /etc/ssh/sshd_config`
if [ "$c" -eq "0" ]
then
    echo "Enable SSH server HostbasedAuthentication"
    echo "HostbasedAuthentication yes" >> /etc/ssh/sshd_config
fi

c=`grep -c "IgnoreRhosts no" /etc/ssh/sshd_config`
if [ "$c" -eq "0" ]
then
    echo "Enable SSH server rhosts authentication"
    echo "IgnoreRhosts no" >> /etc/ssh/sshd_config
fi

c=`grep -c "HostbasedUsesNameFromPacketOnly yes" /etc/ssh/sshd_config`
if [ "$c" -eq "0" ]
then
    echo "Enable SSH server HostbasedUsesNameFromPacketOnly"
    echo "HostbasedUsesNameFromPacketOnly yes" >> /etc/ssh/sshd_config
fi

c=`grep -c "^PermitRootLogin yes" /etc/ssh/sshd_config`
if [ "$c" -eq "0" ]
then
    echo "Enable SSH server root login"
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

cp /etc/hosts.DIST /etc/hosts
rm -f /etc/ssh/shosts.equiv /etc/mpihostfile

while [[ $# -gt 0 ]]
do
    echo "$1 $2" >> /etc/hosts
    echo "$2" >> /etc/ssh/shosts.equiv
    echo "$2 slots=$3 max-slots=$3" >> /etc/mpihostfile
    shift
    shift
    shift
done

cp /etc/ssh/shosts.equiv /root/.rhosts

/etc/init.d/ssh stop
/etc/init.d/ssh start
