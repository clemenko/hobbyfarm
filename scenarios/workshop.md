
# HF - Content

# STIG Background
## RKE2 - STIG

There is a nice article about it from [Businesswire](https://www.businesswire.com/news/home/20221101005546/en/DISA-Validates-Rancher-Government-Solutions%E2%80%99-Kubernetes-Distribution-RKE2-Security-Technical-Implementation-Guide).

You can download the STIG itself from [https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RGS_RKE2_V1R1_STIG.zip](https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RGS_RKE2_V1R1_STIG.zip). 
The SITG viewer can be found on DISA's site at [https://public.cyber.mil/stigs/srg-stig-tools/](https://public.cyber.mil/stigs/srg-stig-tools/). 
For this guide I have simplified the controls and provided simple steps to ensure compliance. Hope this helps a little.

We even have a tl:dr for Rancher https://github.com/clemenko/rancher_stig.

Bottom Line

* Enable SElinux
* Update the config for the Control Plane and Worker nodes.

Enough STIG. Let's start deploying.

---

## RKE2 - Install - node1

If you are bored you can read the [docs](https://docs.rke2.io/). For speed, we are completing an online installation.

There is another git repository with all the air-gapping instructions [https://github.com/clemenko/rke_airgap_install](https://github.com/clemenko/rke_airgap_install).

Heck [watch the video](https://www.youtube.com/watch?v=IkQJc5-_duo).

### node1

#### sudo

We need to sudo and create an account and directory.

```ctr:node1
sudo -i
useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
mkdir -p /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/
```

#### yaml

Next we create a config yaml on node1.

```file:yaml:/etc/rancher/rke2/config.yaml:node1
#profile: cis-1.6
token: bootStrapAllTheThings
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
```

#### tls passthrough

And enable SSL/TLS passthrough for nginx.

```file:yaml:/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml:node1
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

```ctr:node1
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.25 sh - 
systemctl enable --now rke2-server.service
```
```hidden:More info about settings
server install options https://docs.rke2.io/install/configuration#configuring-the-linux-installation-script
```

We should enable kubectl on node1.

#### kubeconfig

We need to set some environment variables.

```ctr:node1
echo "export PATH=$PATH:/usr/local/bin/" >> ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml " >> ~/.bashrc
source ~/.bashrc

# and a sym link
ln -s /var/lib/rancher/rke2/data/v1*/bin/kubectl  /usr/local/bin/kubectl

# lets test
kubectl get node
```

### on to node2

---

## RKE2 - Install - node2

#### sudo

We need to sudo and create an account and directory.

```ctr:node2
sudo -i
mkdir -p /etc/rancher/rke2/
```

#### yaml

Next we create a config yaml on node2.

```file:yaml:/etc/rancher/rke2/config.yaml:node2
#profile: cis-1.6
token: bootStrapAllTheThings
server: https://${vminfo:node1:public_ip}:9345
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
```

#### rke2 install

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:node2
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.25 INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

#### watch - node1

While this is starting we can watch from the node1.

```ctr:node1
kubectl get node -o wide -w
```

### On to node3

---

## RKE2 - Install - node3

#### sudo

We need to sudo and create an account and directory.

```ctr:node3
sudo -i
mkdir -p /etc/rancher/rke2/
```

#### yaml

Next we create a config yaml on node3.

```file:yaml:/etc/rancher/rke2/config.yaml:node3
#profile: cis-1.6
token: bootStrapAllTheThings
server: https://${vminfo:node1:public_ip}:9345
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
```

#### rke2 install

Great. We have all the files setup. We can now install rke2 and start it.

```ctr:node3
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.25 INSTALL_RKE2_TYPE=agent sh - 
systemctl enable --now rke2-agent.service
```

#### watch - node1

While this is starting we can watch from the node1.

```ctr:node1
kubectl get node -o wide -w
```

### We now have a 3 node cluster!

Shall we install some applications?

---

## Rancher - Install

#### install helm

We will need helm on node1

```ctr:node1
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### use helm

We need to add the helm repos for CertManager and Rancher. Then we install.

```ctr:node1
# helm repo add
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest --force-update
helm repo add jetstack https://charts.jetstack.io --force-update

# helm install cert-manager
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

# helm install rancher
helm upgrade -i rancher rancher-latest/rancher --namespace cattle-system --create-namespace --set hostname=${vminfo:node1:hostname} --set bootstrapPassword=Pa22word --set replicas=1
```

We should wait a few seconds for the pods to deploy.

```ctr:node1
kubectl get pod -n cattle-system
```

Once the pod is running we can now navigate to:

https://${vminfo:node1:hostname}

The bootstrap is "Pa22word".

Uncheck "Allow collection..."
and 
Check the EULA box.

### On to Longhorn

---

## Longhorn - Install

#### packages

Before we install longhorn we need to add a few packages to the Rocky vm.

```ctr:node1
yum install -y nfs-utils cryptsetup iscsi-initiator-utils; systemctl enable --now iscsid.service
```

Cool now onto helm.

#### use helm

We need to add the helm repo and then we can install.

```ctr:node1
# helm repo add
helm repo add longhorn https://charts.longhorn.io --force-update

# helm install
helm upgrade -i longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

We should wait a few seconds for the pods to deploy.

```ctr:node1
# check for the pods
kubectl  get pod -n longhorn-system  -o wide

# to verify that longhorn is the default storage class
kubectl get sc
```

Now we can use the Rancher proxy to get to the dashboard.

https://${vminfo:node1:hostname}/k8s/clusters/local/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/#/dashboard

### On to Neuvector

---

## Neuvector - Install

We can continue to use helm.

#### use helm

We need to add the helm repo for Neuvector.

```ctr:node1
# helm repo add
helm repo add neuvector https://neuvector.github.io/neuvector-helm/ --force-update

# helm install 
helm upgrade -i neuvector --namespace cattle-neuvector-system neuvector/core --create-namespace --set imagePullSecrets=regsecret --set k3s.enabled=true --set manager.svc.type=ClusterIP --set controller.pvc.enabled=true --set controller.pvc.capacity=500Mi --set internal.certmanager.enabled=true --set controller.ranchersso.enabled=true --set global.cattle.url=https://${vminfo:node1:hostname}

```

We should wait a few seconds for the pods to deploy.

```ctr:node1
kubectl get pod -n cattle-neuvector-system
```

Now we can use the Rancher proxy to get to the dashboard.

https://${vminfo:node1:hostname}/api/v1/namespaces/cattle-neuvector-system/services/https:neuvector-service-webui:8443/proxy/#/login

### On to production





```ctr:node1
# test 
echo ${vminfo:node1:public_ip}
```

```note:task
Check the nodes.
~~~ctr:node1
kubectl get nodes
~~~
```


curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

yum install -y nfs-utils cryptsetup iscsi-initiator-utils; systemctl enable --now iscsid.service