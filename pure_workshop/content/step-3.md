+++
title = "RKE2 - Install - worker #1 - worker1"
weight = 3
+++

### **A. config - /etc/rancher/rke2/config.yaml**

Next we create a config yaml on worker1.

```file:yaml:/etc/rancher/rke2/config.yaml:worker1
selinux: true
token: bootStrapAllTheThings
server: https://${vminfo:server:public_ip}:9345
```

### **B. rke2 agent install**

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:worker1
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

## **next worker 2**
