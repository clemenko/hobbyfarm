+++
title = "RKE2 - Install - Control Plane - rocky"
weight = 2
+++

Let's start with the control plane node.

### **A. sudo**

We need to sudo and create an account and directory.

```ctr:rocky
sudo -i
```

on to the config yaml

### **B. config - /etc/rancher/rke2/config.yaml**

Next we create a STIG config yaml on rocky.

```file:yaml:/etc/rancher/rke2/config.yaml:rocky
#profile: cis-1.23
token: bootStrapAllTheThings
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
kube-controller-manager-arg:
- bind-address=127.0.0.1
- use-service-account-credentials=true
- tls-min-version=VersionTLS12
- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
kube-scheduler-arg:
- tls-min-version=VersionTLS12
- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
kube-apiserver-arg:
- tls-min-version=VersionTLS12
- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
- authorization-mode=RBAC,Node
- anonymous-auth=false
- audit-policy-file=/etc/rancher/rke2/audit-policy.yaml
- audit-log-mode=blocking-strict
- audit-log-maxage=30
kubelet-arg:
- protect-kernel-defaults=true
- read-only-port=0
- authorization-mode=Webhook
- streaming-connection-idle-timeout=5m
```

### **C. Audit Policy - /etc/rancher/rke2/audit-policy.yaml**

We need to add one more file for the STIG  
audit - /etc/rancher/rke2/audit-policy.yaml

```file:yaml:/etc/rancher/rke2/audit-policy.yaml:rocky
apiVersion: audit.k8s.io/v1
kind: Policy
metadata:
  name: rke2-audit-policy
rules:
  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["*"]
```

Great. We have all the files setup. We can now install rke2 and start it.

### **D. rke2 server install**

Since we are online we can `curl|bash`. See the docs for the airgap install.

```ctr:rocky
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.28 sh - 
systemctl enable --now rke2-server.service
```

### **E. enable kubectl**

We need to set some environment variables.

```ctr:rocky
echo 'export PATH=$PATH:/usr/local/bin/:/var/lib/rancher/rke2/bin/' >> ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml " >> ~/.bashrc
source ~/.bashrc

# lets test
kubectl get node
```

## **next ubuntu worker**
