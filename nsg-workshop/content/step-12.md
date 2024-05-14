+++
title = "Air Gapping with Hauler"
weight = 12
+++

## **Air Gapping with Hauler**

For all the docs check out **https://hauler.dev**.

![hauler logo](https://rancherfederal.github.io/hauler-docs/img/rgs-hauler-logo.png)

### **A. install hauler**

We will run everything as root. aka `sudo -i`.

```ctr:rocky
curl -sfL https://get.hauler.dev | bash
```

### **B. create manifest**

To automate Hauler we need to create a manifest file. Feel free to check out the [Hauler manifest docs](https://rancherfederal.github.io/hauler-docs/docs/guides-references/manifests).

```ctr:rocky
mkdir -p /opt/hauler; cd /opt/hauler
```

Here is an example manifest. We are going to write it to `/opt/hauler/demo_manifest.yaml`.

```file:yaml:/opt/hauler/demo_manifest.yaml:rocky
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Images
metadata:
  name: hauler-content-images-example
  annotations:
    # hauler.dev/key: <cosign public key>
    # hauler.dev/registry: <registry>
    hauler.dev/platform: linux/amd64
spec:
  images:
    - name: neuvector/scanner
    - name: docker.io/neuvector/updater:latest
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Charts
metadata:
  name: hauler-content-charts-example
spec:
  charts:
    - name: rancher
      repoURL: https://releases.rancher.com/server-charts/stable
    - name: rancher
      repoURL: https://releases.rancher.com/server-charts/stable
      version: 2.8.2
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: hauler-content-files-example
spec:
  files:
    - path: https://get.rke2.io
    - path: https://get.rke2.io
      name: install.sh
```

Now let's sync all the bits down.

### **C. hauler sync**

This is a simple command to sync all the bits into a local store directory.

```ctr:rocky
hauler store sync -f /opt/hauler/demo_manifest.yaml -s /opt/hauler/store
```

### **D. hauler store info**

Hauler has a function that can show you what is in the local store. Useful for validating image paths.

```ctr:rocky
hauler store info -s /opt/hauler/store
```

### **E. hauler serve**

Now we can serve out the bits in either a registry or http server.

```ctr:rocky
nohup hauler store serve fileserver -s /opt/hauler/store & 
```

There is also `hauler store serve registry -s /opt/hauler/store` for serving a registry.
We can check it **http://${vminfo:rocky:public_ip}.sslip.io:8080**  
We can clearly ses how Hauler will accelerator the air gapping process.

### **F. extra credit**

For fun check out **https://github.com/clemenko/hauler_hacks/** for a script to create a complete manifest for all the Rancher bits.
Let's create a "Haul" with all the Images/Charts/Files for airgapping. It will take a few minutes to complete.

```ctr:rocky
curl -L https://raw.githubusercontent.com/clemenko/hauler_hacks/main/make_hauler.sh -o /opt/hauler/make_hauler.sh
chmod 755 /opt/hauler/make_hauler.sh
cd /opt/hauler; ./make_hauler.sh
hauler store sync -f airgap_hauler.yaml hauler store info -s /opt/hauler/airstore
```

Did we get everything?

```ctr:rocky
hauler store info -s /opt/hauler/airstore
```
