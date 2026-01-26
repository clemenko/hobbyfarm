+++
title = "Air Gapping with Hauler"
weight = 8
+++

## **Air Gapping with Hauler**

For all the docs check out **https://hauler.dev**.

![hauler logo](https://raw.githubusercontent.com/hauler-dev/hauler-docs/refs/heads/main/static/img/rgs-hauler-logo.png)

### **A. install hauler**

We will run everything as root. aka `sudo -i`.

```ctr:server
curl -sfL https://get.hauler.dev | bash
```

### **B. create manifest**

To automate Hauler we need to create a manifest file. Feel free to check out the [Hauler manifest docs](https://rancherfederal.github.io/hauler-docs/docs/guides-references/manifests).

```ctr:server
mkdir -p /opt/hauler; cd /opt/hauler
```

Here is an example manifest. We are going to write it to `/opt/hauler/demo_manifest.yaml`.

```file:yaml:/opt/hauler/demo_manifest.yaml:server
apiVersion: content.hauler.cattle.io/v1
kind: Files
metadata:
  name: pure-files
spec:
  files:
    #- path: https://releases.purestorage.com/flasharray/purity/6.9.2/purity_6.9.2_202510142333%2Baf11cde1386b.ppkg
    #- path: https://releases.purestorage.com/flasharray/purity/6.9.2/purity_6.9.2_202510142333%2Baf11cde1386b.ppkg.sha1
    #- path: https://raw.githubusercontent.com/PureStorage-OpenConnect/pure-fa-openmetrics-exporter/refs/heads/master/extra/grafana/grafana-purefa-flasharray-overview.json
    - path: https://install.portworx.com/25.8.1/version?kbver=1.32.8
      name: versions.yaml
    - path: https://install.portworx.com/25.8?comp=pxoperator&oem=px-csi&kbver=1.32.3&ns=portworx
      name: operator.yaml
    - path: https://raw.githubusercontent.com/clemenko/px-harvester/refs/heads/main/readme.md
      name: px_harvester.md
    - path: https://raw.githubusercontent.com/clemenko/px-harvester/refs/heads/main/StorageCluster_example.yaml
    - path: https://raw.githubusercontent.com/clemenko/px-harvester/refs/heads/main/airgap_reademe.md
    #- path: https://cloud-images.ubuntu.com/minimal/releases/plucky/release/ubuntu-25.04-minimal-cloudimg-amd64.img
---
apiVersion: content.hauler.cattle.io/v1
kind: Charts
metadata:
  name: portworx-charts
spec:
  charts:
    - name: portworx
      repoURL: http://charts.portworx.io/ 
---
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: rancher-images
  annotations:
    hauler.dev/platform: linux/amd64
spec:       
  images:
```

We need to add the images specifically.

```ctr:server
for i in $(curl -s https://install.portworx.com/25.8.1/images); do echo "    - name: "$i >> /opt/hauler/demo_manifest.yaml ; done
```

Now let's sync all the bits down.

### **C. hauler sync**

This is a simple command to sync all the bits into a local store directory.

```ctr:server
hauler store sync -f /opt/hauler/demo_manifest.yaml -s /opt/hauler/store
```

### **D. hauler store info**

Hauler has a function that can show you what is in the local store. Useful for validating image paths.

```ctr:server
hauler store info -s /opt/hauler/store
```

### **E. hauler serve**

Now we can serve out the bits in either a registry or http server.

```ctr:server
nohup hauler store serve fileserver -s /opt/hauler/store & 
```

There is also `hauler store serve registry -s /opt/hauler/store` for serving a registry.
We can check it **http://${vminfo:server:public_ip}.sslip.io:8080**  
We can clearly ses how Hauler will accelerator the air gapping process.

### **F. extra credit**

For fun check out **https://github.com/clemenko/hauler_hacks/** for a script to create a complete manifest for all the Rancher bits.
Let's create a "Haul" with all the Images/Charts/Files for airgapping. It will take a few minutes to complete.

```ctr:server
curl -L https://raw.githubusercontent.com/clemenko/hauler_hacks/main/make_hauler.sh -o /opt/hauler/make_hauler.sh
chmod 755 /opt/hauler/make_hauler.sh
cd /opt/hauler; ./make_hauler.sh
hauler store sync -f airgap_hauler.yaml
```

Did we get everything?

```ctr:server
hauler store info -s /opt/hauler/airstore
```
