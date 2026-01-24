# Rancher Workshop

![products](https://raw.githubusercontent.com/clemenko/rke_workshop/main/images/rgs-banner-rounded.png)

Welcome, This is an workshop for RKE2/Rancher/Longhorn/NeuVector/Gitea based on an opensource framework [HobbyFarm](https://github.com/hobbyfarm/hobbyfarm).

### Resources

Overview slide deck : [slide_deck.pdf](https://github.com/clemenko/hobbyfarm/blob/main/rancher_workshop/rancher.pdf)

Feel free to watch the video https://youtu.be/jU_w2GWQwxI.

## User Interface

**https://hobbyfarm.rfed.io**

default password **Pa22word**

Each Student will get:

* 4 VMS :
  * **server** ( Rocky 9.4 ) - Control Plane/etcd/Worker
  * **worker1** ( Rocky 9.4 ) - Worker
  * **worker2** ( Rocky 9.4 ) - Worker
  * **z_downstream** ( Rocky 9.4 ) - Downstream

We are Deploying:

* **RKE2** ( STIG'd ) - Kubernetes
* **Rancher** - Multi Cluster Manager
* **Longhorn** - Stateful Storage
* **Foregejo** - Version Control

We are building:
* 2 clusters:
  * **local** 3 nodes/vms
  * **downstream** 1 node - downstream

Check out [Content - Step 1](https://github.com/clemenko/hobbyfarm/blob/main/rancher_workshop/content/step-1.md) of the content.

Hope you enjoy.

## Help

Please feel free to reach out at clemenko@gmail.com
