+++
title = "GitOPS - Gitea - Install"
weight = 8
+++

We can continue to use helm to install Gitea. https://gitea.com

### **A. add helm repo and install**

```ctr:rocky
helm repo add gitea-charts https://dl.gitea.io/charts/ --force-update

helm upgrade -i gitea gitea-charts/gitea --namespace gitea --create-namespace --set gitea.admin.password=Pa22word --set gitea.admin.username=gitea --set persistence.size=500Mi --set gitea.config.server.ROOT_URL=http://git.${vminfo:rocky:public_ip}.sslip.io --set gitea.config.server.DOMAIN=git.${vminfo:rocky:public_ip}.sslip.io --set ingress.enabled=true --set ingress.hosts[0].host=git.${vminfo:rocky:public_ip}.sslip.io --set ingress.hosts[0].paths[0].path=/ --set ingress.hosts[0].paths[0].pathType=Prefix --set postgresql.enabled=false  --set postgresql-ha.enabled=false --set redis-cluster.enabled=false --set gitea.config.database.DB_TYPE=sqlite3 --set gitea.config.session.PROVIDER=memory  --set gitea.config.cache.ADAPTER=memory --set gitea.config.queue.TYPE=level

# wait for it to complete
kubectl wait --for condition=containersready -n gitea pod --all
```

### **B. Mirror upstream git repo**

Once everything is up. We can mirror a demo repo.

```ctr:rocky
# now lets mirror
curl -X POST 'http://git.${vminfo:rocky:public_ip}.sslip.io/api/v1/repos/migrate' -H 'accept: application/json' -H 'authorization: Basic Z2l0ZWE6UGEyMndvcmQ=' -H 'Content-Type: application/json' -d '{ "clone_addr": "https://github.com/clemenko/hobbyfarm", "repo_name": "workshop","repo_owner": "gitea"}'
```

### **C. Edit IP**

####
**CHANGE X.X.X.X to the ${vminfo:rocky:public_ip} in Gitea!**

We need to edit flask yaml : http://git.${vminfo:rocky:public_ip}.sslip.io/gitea/workshop/_edit/main/fleet/flask/flask.yaml 
The username is `gitea`.  
The password is `Pa22word`.

### **On to Fleet**
