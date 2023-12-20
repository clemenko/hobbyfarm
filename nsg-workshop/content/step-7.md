+++
title = "Neuvector"
weight = 7
+++

## NeuVector - Install

We can continue to use helm.

#### use helm

We need to add the helm repo for NeuVector.

```ctr:rocky
# helm repo add
helm repo add neuvector https://neuvector.github.io/neuvector-helm/ --force-update

# helm install 
helm upgrade -i neuvector --namespace cattle-neuvector-system neuvector/core --create-namespace --set imagePullSecrets=regsecret --set k3s.enabled=true --set manager.svc.type=ClusterIP --set controller.pvc.enabled=true --set controller.pvc.capacity=500Mi --set internal.certmanager.enabled=true --set controller.ranchersso.enabled=true --set global.cattle.url=https://rancher.${vminfo:rocky:public_ip}.sslip.io
```

####
We should wait a few seconds for the pods to deploy.

```ctr:rocky
kubectl get pod -n cattle-neuvector-system
```

####
Now we can use the Rancher proxy to get to the dashboard.

**https://rancher.${vminfo:rocky:public_ip}.sslip.io/api/v1/namespaces/cattle-neuvector-system/services/https:neuvector-service-webui:8443/proxy/#/login**

### On to GitOPs
