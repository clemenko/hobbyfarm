+++
title = "RKE2 - Install - Control Plane - server"
weight = 2
+++

Let's start with the control plane node.

### **A. config - /etc/rancher/rke2/config.yaml**

Next we create a config yaml on server.

```file:yaml:/etc/rancher/rke2/config.yaml:server
selinux: true
token: bootStrapAllTheThings
```

Great. We have all the files setup. We can now install rke2 and start it.

### **B. rke2 server install**

Since we are online we can `curl|bash`. See the docs for the airgap install.

```ctr:server
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable sh - 
systemctl enable --now rke2-server.service
```

### **C. enable kubectl**

We need to set some environment variables.

```ctr:server
echo 'export PATH=$PATH:/usr/local/bin/:/var/lib/rancher/rke2/bin/' >> ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml " >> ~/.bashrc
source ~/.bashrc

# lets test
kubectl get node
```

## **next worker 1**
