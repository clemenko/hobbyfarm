+++
title = "Longhorn Install"
weight = 6
+++


## **Longhorn - Install**

### **A. add helm repo and install**

We need to add the helm repo and then we can install.

```ctr:server
# helm install
helm upgrade -i longhorn longhorn --repo https://charts.longhorn.io -n longhorn-system --create-namespace --set ingress.enabled=true,ingress.host=longhorn.${vminfo:server:public_ip}.sslip.io 
```

### **B. Wait and watch the pods deploy**

We should wait a few seconds for the pods to deploy.

```ctr:server
# check for the pods
kubectl  get pod -n longhorn-system

# to verify that longhorn is the default storage class
kubectl get sc
```

### **C. Add encryption StorageClass**

Longhorn has the ability for encryption at rest. We need to enable it.

```ctr:server
kubectl apply -f https://raw.githubusercontent.com/clemenko/k8s_yaml/master/longhorn_encryption.yml

# verify the new storageclass
kubectl get sc
```

### **D. navigate to site**

Now we can check out the dashbaord.

**https://longhorn.${vminfo:server:public_ip}.sslip.io**

### **On to Portworx**
