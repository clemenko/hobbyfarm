+++
title = "NeuVector Install"
weight = 7
+++

We can continue to use helm.

### **A. add helm repo and install**

We need to add the helm repo for NeuVector.

```ctr:rocky
# helm repo add
helm repo add neuvector https://neuvector.github.io/neuvector-helm/ --force-update

# helm install 
helm upgrade -i neuvector --namespace cattle-neuvector-system neuvector/core --create-namespace --set manager.svc.type=ClusterIP --set controller.pvc.enabled=true --set controller.pvc.capacity=500Mi --set controller.ranchersso.enabled=true --set global.cattle.url=https://rancher.${vminfo:rocky:public_ip}.sslip.io
```

### **B. Wait and watch the pods deploy**

We should wait a few seconds for the pods to deploy.

```ctr:rocky
kubectl get pod -n cattle-neuvector-system
```

### **C. navigate to site**

Now we can use the Rancher proxy to get to the dashboard.

**https://rancher.${vminfo:rocky:public_ip}.sslip.io/api/v1/namespaces/cattle-neuvector-system/services/https:neuvector-service-webui:8443/proxy/#/login**

### **On to GitOPs**
