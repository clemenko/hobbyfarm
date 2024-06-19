+++
title = "Rancher Install"
weight = 5
+++

### **A. install helm**

We will need helm on rocky

```ctr:rocky
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### **B. add helm repos**

We need to add the helm repos for CertManager and Rancher. Then we install.

```ctr:rocky
# helm repo add
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest --force-update
helm repo add jetstack https://charts.jetstack.io --force-update
```

### **C. install cert-manager and rancher**

We use `helm upgrade -i` to install.

```ctr:rocky
# helm install cert-manager
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

# helm install rancher
helm upgrade -i rancher rancher-latest/rancher --namespace cattle-system --create-namespace --set hostname=rancher.${vminfo:rocky:public_ip}.sslip.io --set bootstrapPassword=Pa22word --set replicas=1
```

### **D. check rancher pod**

We should wait a few seconds for the pods to deploy.

```ctr:rocky
kubectl get pod -n cattle-system
```

### **E. navigate to site**

Once the pod is running we can now navigate to:

**https://rancher.${vminfo:rocky:public_ip}.sslip.io**  
**The bootstrap is "Pa22word".**

### **F. accept eula**

Uncheck "Allow collection..."  
and  
Check the EULA box.

## **On to Longhorn**
