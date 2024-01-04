+++
title = "RKE2 - Install - ubuntu"
weight = 3
+++

## RKE2 - Install - Worker #1 - ubuntu

#### sudo

We need to sudo and create an account and directory.

```ctr:ubuntu
sudo -i
mkdir -p /etc/rancher/rke2/
```

#### config - /etc/rancher/rke2/config.yaml

Next we create a config yaml on ubuntu.

```file:yaml:/etc/rancher/rke2/config.yaml:ubuntu
#profile: cis-1.23
selinux: true
token: bootStrapAllTheThings
server: https://${vminfo:rocky:public_ip}:9345
write-kubeconfig-mode: 0600
kube-apiserver-arg:
- authorization-mode=RBAC,Node
kubelet-arg:
- protect-kernel-defaults=true
- read-only-port=0
- authorization-mode=Webhook
```

#### rke2 install

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:ubuntu
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.26 INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

### On to sles
