## Install

Basically 2 paths :

### DO - Install Script

May be worth looking at the [hobbyfarm.sh](hobbyfarm.sh) script.  
It uses a DigitalOcean VM to serve the Admin and User HobbyFarm interfaces.

```bash
./hobbyfarm.sh up
```

When done.

```bash
./hobbyfarm.sh kill
```

### Manual on any K8s Cluster

Here are the steps for any cluster.

```bash
# Add helm repo
helm repo add hobbyfarm https://hobbyfarm.github.io/hobbyfarm --force-update > /dev/null 2>&1

### Create Namespace
kubectl create namespace hobbyfarm > /dev/null 2>&1

### Create Certificates
kubectl -n hobbyfarm create secret generic tls-ca --from-file=/Users/clemenko/Dropbox/work/rfed.me/io/cacerts.pem  > /dev/null 2>&1
kubectl -n hobbyfarm create secret tls tls-hobbyfarm-certs  --cert=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.cert --key=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.key > /dev/null 2>&1

### adding logos
kubectl create configmap rgs-logo -n hobbyfarm --from-file=rancher-labs-stacked-color.svg=rfed-logo-stacked.svg > /dev/null 2>&1

### add creds - set the variables on the shell
# set export ACCESS_KEY=...
# set export SECRET_KEY=...
# set export DO_TOKEN=...
kubectl create secret -n hobbyfarm generic aws-creds --from-literal=access_key=$ACCESS_KEY --from-literal=secret_key=$SECRET_KEY > /dev/null 2>&1
kubectl create secret -n hobbyfarm generic do-token --from-literal=token=$DO_TOKEN > /dev/null 2>&1

### Install Hobbyfarm
# pay attention to the URLS.
helm upgrade -i hobbyfarm chart/ -n hobbyfarm --set ingress.enabled=true --set ingress.tls.enabled=true --set ingress.tls.secrets.backend=tls-hobbyfarm-certs --set ingress.tls.secrets.admin=tls-hobbyfarm-certs --set ingress.tls.secrets.ui=tls-hobbyfarm-certs --set ingress.tls.secrets.shell=tls-hobbyfarm-certs --set ingress.hostnames.backend=backend.rfed.io --set ingress.hostnames.admin=hobby-admin.rfed.io --set ingress.hostnames.ui=hobbyfarm.rfed.io --set ingress.hostnames.shell=hobby-shell.rfed.io  --set ui.config.title="RGS - Workshop"  --set ui.config.login.customlogo=rgs-logo --set terraform.enabled=true --set shell.replicas=3 --set gargantua.image=ebauman/gargantua:pr-154-3 > /dev/null 2>&1

# digitalocean provider 
# https://github.com/hobbyfarm/hf-provisioner-digitalocean
helm install hf-provisioner-digitalocean hf-provisioner-digitalocean/chart/hf-provisioner-digitalocean --namespace hobbyfarm > /dev/null 2>&1
```

## Content - Course

Right now all the settings and the workshop are in the [settings.yaml](settings.yaml) file.  
The settings adds the admin user and 40 users (user1...user41).  
**ALL passwords are "Pa22word"**

The URLS are in the `helm` command. Pay attention that you have DNS and certs in place for them.

Updating the settings is as easy as `kubectl apply -f settings.yaml`.

Here is the human read-able [nsg-workshop.md](nsg-workshop.md) for the basic scenario.

### notes

HobbyFarm does have a cool way to write content that is clickable. They call it [Special Markdown Syntax](https://hobbyfarm.github.io/docs/appendix/markdown_syntax/)

Here is an example of Click-To-Run.

```ctr:node1
# test 
echo ${vminfo:node1:public_ip}
```

And an example of notes.

```note:task
Check the nodes.
~~~ctr:node1
kubectl get nodes
~~~
```

## hfcli

There is now a working cli for creating/retreiving scenarios. https://github.com/hobbyfarm/hfcli/

notes:

```
# get scneario 
hfcli -k ~/.kube/config -n hobbyfarm get scenario nsg-workshop nsg-workshop

# apply
hfcli -k ~/.kube/config -n hobbyfarm apply scenario nsg-workshop nsg-workshop/
```