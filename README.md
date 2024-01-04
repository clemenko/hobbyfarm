# NSG - Workshop

![products](https://raw.githubusercontent.com/clemenko/rke_workshop/main/images/rgs-banner-rounded.png)

Welcome, This is an workshop for RKE2/Rancher/Longhorn/NeuVector/Gitea based on an opensource framework [HobbyFarm](https://github.com/hobbyfarm/hobbyfarm). HobbyFarm is a great tool for web based training.

## Slide deck

Overview slide deck : [clemenko_master.pdf](https://github.com/clemenko/hobbyfarm/blob/main/clemenko_master.pdf)

## NSG Workshop

Each Student will have their own workspace!

Deploying:
* **RKE2** ( STIG'd ) - Kubernetes
* **Rancher** - Multi Cluster Manager
* **Longhorn** - Stateful Storage
* **NeuVector** - Container Security
* **Gitea** - Version Control

We are building:
* 4 VMS :
  * **rocky** ( Rocky 9.3 ) - Control Plane/etcd/Worker
  * **ubuntu** ( Ubuntu 22.04 ) - Worker
  * **sles** ( SLES 15 - SP4 ) - Worker
  * **z_downstream** ( Rocky 9.3 ) - Downstream
* 2 clusters:
  * **local** 3 nodes/vms
  * **downstream** 1 node - downstream

Check out [step-1.md](https://github.com/clemenko/hobbyfarm/blob/main/nsg-workshop/content/step-1.md) of the content.

Hope you enjoy.

## More Resources

https://rfed.io/links

## Help

Please feel free to reach out at clemenko@gmail.com
