+++
title = "Longhorn"
weight = 6
+++


## Longhorn - Install

#### packages

Before we install longhorn we need to add a few packages to the Rocky vm.

```ctr:rocky
# for rocky
yum install -y nfs-utils cryptsetup iscsi-initiator-utils; systemctl enable --now iscsid.service
```

```ctr:ubuntu
# for ubuntu
systemctl disable ufw --now
export DEBIAN_FRONTEND=noninteractive; apt update; apt install nfs-common -y
```

```ctr:sles
# for sles
zypper install -y open-iscsi
zypper install -y nfs-client
```

Cool now onto helm.

#### use helm

We need to add the helm repo and then we can install.

```ctr:rocky
# helm repo add
helm repo add longhorn https://charts.longhorn.io --force-update

# helm install
helm upgrade -i longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

####
We should wait a few seconds for the pods to deploy.

```ctr:rocky
# check for the pods
kubectl  get pod -n longhorn-system  -o wide

# to verify that longhorn is the default storage class
kubectl get sc
```

#### encryption?

Longhorn has the ability for encryption at rest. We need to enable it.

```ctr:rocky
kubectl apply -f https://raw.githubusercontent.com/clemenko/k8s_yaml/master/longhorn_encryption.yml

# verify the new storageclass
kubectl get sc
```

####
Now we can use the Rancher proxy to get to the dashboard.

**https://rancher.${vminfo:rocky:public_ip}.sslip.io/k8s/clusters/local/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/#/dashboard**

### On to NeuVector
