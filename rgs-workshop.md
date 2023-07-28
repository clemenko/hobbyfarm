## Introduction
**Welcome.**

![products](https://raw.githubusercontent.com/clemenko/rke_workshop/main/images/rgs-banner-rounded.png)

####
This training platform is open-source. And can be found at https://github.com/hobbyfarm/hobbyfarm.

####
The good news is that all the fields are clickable and do not require copying and pasting. This will create great success.

####
We are building 3 vms:
* **rocky** ( Rocky 9.2 ) - Control Plane/etcd/Worker
* **ubuntu** ( Ubuntu 22.04 ) - Worker
* **sles** ( SLES 15 - SP4 ) - Worker

####
Hope we have some fun.

---
## RKE2 - Install - rocky

If you are bored you can read the [docs](https://docs.rke2.io/). For speed, we are completing an online installation.

There is another git repository with all the air-gapping instructions [https://github.com/clemenko/rke_airgap_install](https://github.com/clemenko/rke_airgap_install).

#### sudo

We need to sudo and create an account and directory.

```ctr:rocky
sudo -i
useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
mkdir -p /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/
```

#### config.yaml

Next we create a config yaml on rocky.

```file:yaml:/etc/rancher/rke2/config.yaml:rocky
#profile: cis-1.6
token: bootStrapAllTheThings
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
```

#### nginx tls passthrough

And enable SSL/TLS passthrough for nginx.

```file:yaml:/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml:rocky
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-ingress-nginx
  namespace: kube-system
spec:
  valuesContent: |-
    controller:
      config:
        use-forwarded-headers: true
      extraArgs:
        enable-ssl-passthrough: true
```

Great. We have all the files setup. We can now install rke2 and start it.

#### rke2 install

```ctr:rocky
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.25 sh - 
systemctl enable --now rke2-server.service
```

```hidden:More info about settings
server install options https://docs.rke2.io/install/configuration#configuring-the-linux-installation-script
```

We should enable kubectl on rocky.

#### kubeconfig

We need to set some environment variables.

```ctr:rocky
echo "export PATH=$PATH:/usr/local/bin/" >> ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml " >> ~/.bashrc
source ~/.bashrc

# and a sym link
ln -s /var/lib/rancher/rke2/data/v1*/bin/kubectl  /usr/local/bin/kubectl

# lets test
kubectl get node
```

### on to ubuntu

---

## RKE2 - Install - ubuntu

#### sudo

We need to sudo and create an account and directory.

```ctr:ubuntu
sudo -i
mkdir -p /etc/rancher/rke2/
```

#### yaml

Next we create a config yaml on ubuntu.

```file:yaml:/etc/rancher/rke2/config.yaml:ubuntu
#profile: cis-1.6
token: bootStrapAllTheThings
server: https://${vminfo:rocky:public_ip}:9345
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
```

#### rke2 install

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:ubuntu
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.25 INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

#### watch - rocky

While this is starting we can watch from the rocky.

```ctr:rocky
watch -n 5 kubectl get node -o wide
```

### On to sles

---

## RKE2 - Install - sles

#### sudo

We need to sudo and create an account and directory.

```ctr:sles
sudo -i
mkdir -p /etc/rancher/rke2/
```

#### yaml

Next we create a config yaml on sles.

```file:yaml:/etc/rancher/rke2/config.yaml:sles
#profile: cis-1.6
token: bootStrapAllTheThings
server: https://${vminfo:rocky:public_ip}:9345
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
```

#### rke2 install

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:sles
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.25 INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

#### watch - rocky

While this is starting we can click on the rocky tab to watch.

### We now have a 3 node cluster!

We should talk about the STIG next.

---

## RKE2 - STIG

There is a nice article about it from [Businesswire](https://www.businesswire.com/news/home/20221101005546/en/DISA-Validates-Rancher-Government-Solutions%E2%80%99-Kubernetes-Distribution-RKE2-Security-Technical-Implementation-Guide).

You can download the STIG itself from [https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RGS_RKE2_V1R1_STIG.zip](https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RGS_RKE2_V1R1_STIG.zip).   
The SITG viewer can be found on DISA's site at [https://public.cyber.mil/stigs/srg-stig-tools/](https://public.cyber.mil/stigs/srg-stig-tools/). For this guide I have simplified the controls and provided simple steps to ensure compliance. Hope this helps a little.

We even have a tl:dr for Rancher https://github.com/clemenko/rancher_stig.

Bottom Line

* Enable SElinux
* Update the config for the Control Plane and Worker nodes.

Enough STIG. Let's start deploying applications like Rancher

---

## Rancher - Install

#### install helm

We will need helm on rocky

```ctr:rocky
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### use helm

We need to add the helm repos for CertManager and Rancher. Then we install.

```ctr:rocky
# helm repo add
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest --force-update
helm repo add jetstack https://charts.jetstack.io --force-update

# helm install cert-manager
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

# helm install rancher
helm upgrade -i rancher rancher-latest/rancher --namespace cattle-system --create-namespace --set hostname=rancher.${vminfo:rocky:public_ip}.sslip.io --set bootstrapPassword=Pa22word --set replicas=1
```

####
We should wait a few seconds for the pods to deploy.

```ctr:rocky
kubectl get pod -n cattle-system
```

####
Once the pod is running we can now navigate to:

**https://rancher.${vminfo:rocky:public_ip}.sslip.io**  
**The bootstrap is "Pa22word".**

####
Uncheck "Allow collection..."  
and  
Check the EULA box.

### On to Longhorn

---

## Longhorn - Install

#### packages

Before we install longhorn we need to add a few packages to the Rocky vm.

```ctr:rocky
# for rocky
yum install -y nfs-utils cryptsetup iscsi-initiator-utils; systemctl enable --now iscsid.service
```

```ctr:ubuntu
# for ubuntu
systemctl disable ufw --now
export DEBIAN_FRONTEND=noninteractive; apt update; apt install nfs-common -y
```

```ctr:sles
# for sles
zypper install -y open-iscsi
zypper install -y nfs-client
```

Cool now onto helm.

#### use helm

We need to add the helm repo and then we can install.

```ctr:rocky
# helm repo add
helm repo add longhorn https://charts.longhorn.io --force-update

# helm install
helm upgrade -i longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

####
We should wait a few seconds for the pods to deploy.

```ctr:rocky
# check for the pods
kubectl  get pod -n longhorn-system  -o wide

# to verify that longhorn is the default storage class
kubectl get sc
```

#### encryption?

Longhorn has the ability for encryption at rest. We need to enable it.

```ctr:rocky
kubectl apply -f https://raw.githubusercontent.com/clemenko/k8s_yaml/master/longhorn_encryption.yml

# verify the new storageclass
kubectl get sc
```

####
Now we can use the Rancher proxy to get to the dashboard.

**https://rancher.${vminfo:rocky:public_ip}.sslip.io/k8s/clusters/local/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/#/dashboard**

### On to NeuVector

---

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

---

## GitOPs - Gitea - Install

We can continue to use helm to install Gitea. https://gitea.com

#### use helm

```ctr:rocky
helm repo add gitea-charts https://dl.gitea.io/charts/ --force-update

helm upgrade -i gitea gitea-charts/gitea --namespace gitea --create-namespace --set gitea.admin.password=Pa22word --set gitea.admin.username=gitea --set persistence.size=500Mi --set gitea.config.server.ROOT_URL=http://git.${vminfo:rocky:public_ip}.sslip.io --set gitea.config.server.DOMAIN=git.${vminfo:rocky:public_ip}.sslip.io --set ingress.enabled=true --set ingress.hosts[0].host=git.${vminfo:rocky:public_ip}.sslip.io --set ingress.hosts[0].paths[0].path=/ --set ingress.hosts[0].paths[0].pathType=Prefix --set postgresql-ha.enabled=false --set redis-cluster.enabled=false --set gitea.config.database.DB_TYPE=sqlite3 --set gitea.config.session.PROVIDER=memory  --set gitea.config.cache.ADAPTER=memory --set gitea.config.queue.TYPE=level

# wait for it to complete
watch kubectl get pod -n gitea
```

#### running?
Once everything is up. We can mirror a demo repo.

```ctr:rocky
# now lets mirror
curl -X POST 'http://git.${vminfo:rocky:public_ip}.sslip.io/api/v1/repos/migrate' -H 'accept: application/json' -H 'authorization: Basic Z2l0ZWE6UGEyMndvcmQ=' -H 'Content-Type: application/json' -d '{ "clone_addr": "https://github.com/clemenko/hobbyfarm", "repo_name": "workshop","repo_owner": "gitea"}'
```
   
#### navigate

Navigate to **http://git.${vminfo:rocky:public_ip}.sslip.io**  
The username is `gitea`.  
The password is `Pa22word`.

####
We need to edit flask yaml : http://git.${vminfo:rocky:public_ip}.sslip.io/gitea/workshop/_edit/main/fleet/flask/flask.yaml

**CHANGE X.X.X.X to the ${vminfo:rocky:public_ip} in Gitea!**

### On to Fleet

---

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

---

## Stop when you get here

We will walk through all the interfaces together.

To review the content please check out:  
**[https://github.com/clemenko/hobbyfarm](https://github.com/clemenko/hobbyfarm/blob/main/rgs-workshop.md)**

![success](https://raw.githubusercontent.com/clemenko/rke_workshop/main/images/success.jpg)

Thanks for playing!
