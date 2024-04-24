+++
title = "GitOPS - Fleet - Setup"
weight = 9
+++

Fleet is already installed within Rancher.  
We need to create a `GitRepo` file to tell Fleet where the repo is.

### **A. create gitrepo file**

The gitrepo object is used by fleet to describe where the git repo to be used.

```file:yaml:/root/gitea.yaml:rocky
kind: GitRepo
apiVersion: fleet.cattle.io/v1alpha1
metadata:
  name: versions
  namespace: fleet-local
spec:
  branch: main
  insecureSkipTLSVerify: true
  repo: http://git.${vminfo:rocky:public_ip}.sslip.io/gitea/workshop
  targetNamespace: versions
  paths:
  - fleet/versions
```

### **B. deploy gitrepo file**

We can now deploy the file to add to Fleet.

```ctr:rocky
kubectl apply -f /root/gitea.yaml
```

### **C. navigate to site**

Now we can Navigate to https://rancher.${vminfo:rocky:public_ip}.sslip.io/dashboard/c/local/fleet/fleet.cattle.io.gitrepo  
Change "fleet-default" to "fleet-local" in the top right corner.  
We can see everything come up.

to: **http://versions.${vminfo:rocky:public_ip}.sslip.io**  

### **On to Challenge A**
