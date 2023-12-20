+++
title = "GitOPS - Fleet - Setup"
weight = 9
+++


## GitOPs - Fleet - Setup

Fleet is already installed within Rancher.  
We need to create a `GitRepo` file to tell Fleet where the repo is.

```file:yaml:/root/gitea.yaml:rocky
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
```

We can now deploy the file to add to Fleet.

```ctr:rocky
kubectl apply -f /root/gitea.yaml
```

Now we can Navigate to https://rancher.${vminfo:rocky:public_ip}.sslip.io/dashboard/c/local/fleet/fleet.cattle.io.gitrepo  
Change "fleet-default" to "fleet-local" in the top right corner.  
We can see everything come up.

#### navigate

to: **http://flask.${vminfo:rocky:public_ip}.sslip.io**  

### On to Profit
