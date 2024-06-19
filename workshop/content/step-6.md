+++
title = "Longhorn Install"
weight = 6
+++


## **Longhorn - Install**

### **A. add helm repo and install**

We need to add the helm repo and then we can install.

```ctr:rocky
# helm repo add
helm repo add longhorn https://charts.longhorn.io --force-update

# helm install
helm upgrade -i longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

### **B. Wait and watch the pods deploy**

We should wait a few seconds for the pods to deploy.

```ctr:rocky
# check for the pods
kubectl  get pod -n longhorn-system

# to verify that longhorn is the default storage class
kubectl get sc
```

### **C. Add encryption StorageClass**

Longhorn has the ability for encryption at rest. We need to enable it.

```ctr:rocky
kubectl apply -f https://raw.githubusercontent.com/clemenko/k8s_yaml/master/longhorn_encryption.yml

# verify the new storageclass
kubectl get sc
```

### **D. navigate to site**

Now we can use the Rancher proxy to get to the dashboard.

**https://rancher.${vminfo:rocky:public_ip}.sslip.io/k8s/clusters/local/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/#/dashboard**

### **On to NeuVector**
