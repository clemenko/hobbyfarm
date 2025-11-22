+++
title = "PortWorx Install"
weight = 7
+++

The good news is that installing PX-CSI is fairly simple. These are the steps with some fake values.

### **A. create namespace and json**

We are simulating the install. The IP of the array is fake. The API token is also fake.

```ctr:server
# get latest version of PX-CSI
PX_CSI_VER=$(curl -sL https://dzver.rfed.io/json | jq -r .portworx)

# create namespace
kubectl create ns portworx

# create and add secret
cat << EOF > pure.json 
{
    "FlashArrays": [
        {
            "MgmtEndPoint": "192.168.1.11",
            "APIToken": "934f95b6-6d1d-ee91-d210-6ed9bce13ad1"
        }
    ]
}
EOF

kubectl create secret generic px-pure-secret -n portworx --from-file=pure.json=pure.json
```

### **B. Deploy the operator**

```ctr:server
kubectl apply -f 'https://install.portworx.com/'$PX_CSI_VER'?comp=pxoperator&oem=px-csi&kbver=1.33.5&ns=portworx'
```

### **C. Add the StorageCluster object**

We have a couple of options here.
- "portworx.io/health-check: "skip" " for running on a single node
- value: "NVMEOF-TCP"

```ctr:server
cat << EOF | kubectl apply -n portworx  -f -
kind: StorageCluster
apiVersion: core.libopenstorage.org/v1
metadata:
  name: px-cluster
  namespace: portworx
  annotations:
    portworx.io/misc-args: "--oem px-csi"
    #portworx.io/health-check: "skip"
spec:
  image: portworx/px-pure-csi-driver:$PX_CSI_VER
  imagePullPolicy: IfNotPresent
  csi:
    enabled: true
  monitoring:
    telemetry:
      enabled: false
    prometheus:
      enabled: false
      exportMetrics: false
  env:
  - name: PURE_FLASHARRAY_SAN_TYPE
    value: "ISCSI"
EOF
```

### **D. verify**

```ctr:server
kubectl get pod -n portworx
```

### **On to GitOPs**
