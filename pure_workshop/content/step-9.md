+++
title = "But Wait!"
weight = 9
+++

## **But Wait...**

Lets deploy an application!

### **A. Get yaml**

Let's deploy a little flask. But first lets see what storage we have.

```ctr:server
kubectl get pvc -A
kubectl get pv -A
kubectl get storageclass
```

What did we see?  
Now the app.

```ctr:server
curl -L https://raw.githubusercontent.com/clemenko/hobbyfarm/refs/heads/main/fleet/flask/flask.yaml | sed  's/X.X.X.X/${vminfo:server:public_ip}/g' | kubectl apply -f -n flask - 
```

check the pods

```ctr:server
kubectl get pod,ingress -n flask
```

### **B. navigate to site**

Now we can check out the dashboard.

**https://flask.${vminfo:server:public_ip}.sslip.io**

### **C. chaos engineering**

For fun let's delete the redis pod.

```ctr:server
kubectl delete pod -n flask redis
```

Does it come back?
