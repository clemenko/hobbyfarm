+++
title = "GitOPS - Fleet - Setup"
weight = 9
+++

Fleet is already installed within Rancher.  
We need to create a `GitRepo` file to tell Fleet where the repo is.

### **A. create gitrepo file**

The gitrepo object is used by fleet to describe where the git repo to be used. We can write/deploy it with a simple command.

```ctr:rocky
cat << EOF | kubectl apply -f -
kind: GitRepo
apiVersion: fleet.cattle.io/v1alpha1
metadata:
  name: flask
  namespace: fleet-local
spec:
  branch: main
  insecureSkipTLSVerify: true
  repo: http://git.${vminfo:rocky:public_ip}.sslip.io/gitea/workshop
  targetNamespace: flask
  paths:
  - fleet/flask
EOF
```

### **B. navigate to site**

Now we can Navigate to https://rancher.${vminfo:rocky:public_ip}.sslip.io/dashboard/c/local/fleet/fleet.cattle.io.gitrepo  
Change "fleet-default" to "fleet-local" in the top right corner.  
We can see everything come up.

to: **http://flask.${vminfo:rocky:public_ip}.sslip.io**  

### **On to Challenge A**
