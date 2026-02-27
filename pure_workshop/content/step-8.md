+++
title = "PortWorx PX-CLI Install"
weight = 7
+++

The good news is that installing PX-CLI is fairly simple.

First we should look at the docs : https://docs.portworx.com/px-cli/

### **A. Install**

```ctr:server
# install
curl -sfL https://mirrors.portworx.com/packages/px-cli/latest/px-v1.1.0.linux.amd64.tar.gz | tar -xzf -

# copy files
rsync -avP px/bin/* /usr/local/bin/

# give it permissions
chmod +x /usr/local/bin/px*

# clean up
rm -rf px
```

We can review all the commands available : https://docs.portworx.com/px-cli/px-csi

### **B. play with px-cli**

Let play with `px-cli`.

```ctr:server
# version
px version

# status
px csi status

# List all volumes in PX-CSI
kubectl px csi list volume
```

### **On to Hauler**
