+++
title = "Rancher Install"
weight = 5
+++

### **A. install helm**

We will need helm on server

```ctr:server
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### **B. install cert-manager and rancher**

We use `helm upgrade -i` to install.

```ctr:server
# helm install cert-manager
helm upgrade -i cert-manager cert-manager --repo https://charts.jetstack.io -n cert-manager --create-namespace --set crds.enabled=true

# helm install rancher
helm upgrade -i rancher rancher --repo https://releases.rancher.com/server-charts/latest --namespace cattle-system --create-namespace --set hostname=rancher.${vminfo:server:public_ip}.sslip.io --set bootstrapPassword=Pa22word --set replicas=1
```

### **C. check rancher pod**

We should wait a few seconds for the pods to deploy.

```ctr:server
kubectl get pod -n cattle-system
```

### **D. navigate to site**

Once the pod is running we can now navigate to:

**https://rancher.${vminfo:server:public_ip}.sslip.io**  
**The bootstrap is "Pa22word".**

### **E. accept eula**

Uncheck "Allow collection..."  
and  
Check the EULA box.

## **On to Longhorn**
