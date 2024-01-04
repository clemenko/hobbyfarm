+++
title = "RKE2 - Install - rocky"
weight = 2
+++


## RKE2 - Install - Control Plane - rocky

If you are bored you can read the [docs](https://docs.rke2.io/). For speed, we are completing an online installation.

#### sudo

We need to sudo and create an account and directory.

```ctr:rocky
sudo -i
mkdir -p /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/
```

on to the config yaml

#### config - /etc/rancher/rke2/config.yaml

Next we create a STIG config yaml on rocky.

```file:yaml:/etc/rancher/rke2/config.yaml:rocky
#profile: cis-1.23
token: bootStrapAllTheThings
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0640
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

#### rke2 install

```ctr:rocky
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.26 sh - 
systemctl enable --now rke2-server.service
```

```hidden:More info about settings
server install options https://docs.rke2.io/install/configuration#configuring-the-linux-installation-script
```

We should enable kubectl on rocky.

#### kubeconfig

We need to set some environment variables.

```ctr:rocky
echo 'export PATH=$PATH:/usr/local/bin/:/var/lib/rancher/rke2/bin/' >> ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml " >> ~/.bashrc
source ~/.bashrc

# lets test
kubectl get node
```

### on to ubuntu
