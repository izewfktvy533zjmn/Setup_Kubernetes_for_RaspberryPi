#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo 'You are not root.'
    echo 'You need to be root authority to execute.'
    exit 1
fi


if [ -f /etc/systemd/system/kubelet.service.d/10-kubeadm.conf ]; then
    cp /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bk /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    rm /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bk
fi


if [ -f /etc/rc.local ]; then
    cp /etc/rc.local /etc/rc.local.bk
    rm -f /etc/rc.local
fi

touch /etc/rc.local
chmod 755 /etc/rc.local

while read line
do
    if [ "$line" = "systemctl daemon-reload" ]; then
        echo >> /dev/null
    else
        echo $line >> /etc/rc.local
    fi
    
done < /etc/rc.local.bk


apt-mark unhold kubeadm kubectl kubelet kubernetes-cni
apt remove --purge -y kubelet=1.10.5-00 kubeadm=1.10.5-00 kubectl=1.10.5-00 kubernetes-cni=0.6.0-00
rm /etc/apt/sources.list.d/kubernetes.list

update-rc.d dphys-swapfile enable
dphys-swapfile install
dphys-swapfile swapon
systemctl enable dphys-swapfile


exit 0
