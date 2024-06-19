+++
title = "RKE2 - Install - worker #2 - sles"
weight = 4
+++

### **A. sudo**

We need to sudo and create an account and directory.

```ctr:sles
sudo -i
```

### **B. config - /etc/rancher/rke2/config.yaml**

Next we create a config yaml on ubuntu.

```file:yaml:/etc/rancher/rke2/config.yaml:sles
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

### **C. rke2 agent install**

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:sles
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.28 INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

### **D. watch nodes**

While this is starting we can watch the nodes join from the rocky node.

```ctr:rocky
watch kubectl get node
```

## **We now have a 3 node cluster, lets install Rancher**
