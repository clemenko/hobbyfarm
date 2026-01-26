#!/usr/bin/env bash
# script to build a single vm with k3s and hobby-farm

password=Pa22word
domain=rfed.io

######  NO MOAR EDITS #######
export RED='\x1b[0;31m'
export GREEN='\x1b[32m'
export BLUE='\x1b[34m'
export YELLOW='\x1b[33m'
export NO_COLOR='\x1b[0m'

# builds a vm list
function dolist () { doctl compute droplet list --format "ID,Name,PublicIPv4,Memory,VCPUs,Region,Image,Status" |grep hobby |sort -k 2; }

################################# up ################################
function up () {

echo -e -n " building hobbyfarm vm "
# do
doctl compute droplet create hobbyfarm --region nyc1 --image rockylinux-9-x64 --size s-8vcpu-16gb-amd --ssh-keys 30:98:4f:c5:47:c2:88:28:fe:3c:23:cd:52:49:51:01 --wait --droplet-agent=false > /dev/null 2>&1

sleep 10

echo -e "$GREEN" "ok" "$NO_COLOR"

#check for SSH
echo -e -n " checking for ssh "

server=$(dolist | awk '{print $3'})

until [ $(ssh -o ConnectTimeout=1 root@$server 'exit' 2>&1 | grep 'timed out\|refused' | wc -l) = 0 ]; do echo -e -n "." ; sleep 5; done
echo -e "$GREEN" "ok" "$NO_COLOR"

#update DNS
echo -e -n " updating dns"
doctl compute domain records create $domain --record-type A --record-name hobbyfarm --record-ttl 60 --record-data $server > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name hobby-admin --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name hobby-backend --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name hobby-shell --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
echo -e "$GREEN" "ok" "$NO_COLOR"

sleep 20

echo -e -n " installing rke2"

ssh root@$server 'mkdir -p /etc/rancher/rke2/; echo -e "\ntls-san:\n- "'$server'"\nkubelet-arg:\n- max-pods=400" > /etc/rancher/rke2/config.yaml; curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable sh - ; systemctl enable --now rke2-server.service' > /dev/null 2>&1

sleep 10

ssh root@$server cat /etc/rancher/rke2/rke2.yaml | sed  -e "s/127.0.0.1/$server/g" > ~/.kube/config 
chmod 0600 ~/.kube/config

echo -e "$GREEN" "ok" "$NO_COLOR"

echo -e -n " - rke2 active "
sleep 5
until [ $(kubectl get node|grep NotReady|wc -l) = 0 ]; do echo -e -n "."; sleep 2; done
echo -e "$GREEN" "ok" "$NO_COLOR"

############   hobbyfarm install   ############
### Add Helm Repo
echo -e -n " - deploying hobbyfarm "

### Create Namespace
kubectl create namespace hobbyfarm > /dev/null 2>&1

### Create Certificates
kubectl -n hobbyfarm create secret generic tls-ca --from-file=/Users/clemenko/Dropbox/work/rfed.me/io/cacerts.pem  > /dev/null 2>&1
kubectl -n hobbyfarm create secret tls tls-hobbyfarm-certs  --cert=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.cert --key=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.key > /dev/null 2>&1

### add creds - set the variables on the shell
kubectl create secret -n hobbyfarm generic do-token --from-literal=token=$DO_TOKEN > /dev/null 2>&1

### Install Hobbyfarm
helm upgrade -i hobbyfarm hobbyfarm --repo https://hobbyfarm.github.io/hobbyfarm -n hobbyfarm -f ./values.yaml > /dev/null 2>&1

#helm upgrade -i hobbyfarm hobbyfarm --repo https://hobbyfarm.github.io/hobbyfarm -n hobbyfarm --set ingress.enabled=true --set ingress.tls.enabled=true --set ingress.tls.secrets.backend=tls-hobbyfarm-certs --set ingress.tls.secrets.admin=tls-hobbyfarm-certs --set ingress.tls.secrets.ui=tls-hobbyfarm-certs --set ingress.tls.secrets.shell=tls-hobbyfarm-certs --set ingress.hostnames.backend=hobby-backend.$domain --set ingress.hostnames.admin=hobby-admin.$domain --set ingress.hostnames.ui=hobbyfarm.$domain --set ingress.hostnames.shell=hobby-shell.$domain --set ingress.className=nginx --set general.dynamicBaseNamePrefix="hobby" > /dev/null 2>&1

sleep 60

### install do prov
helm upgrade -i  hf-provisioner-digitalocean ./hf-provisioner-digitalocean/chart/hf-provisioner-digitalocean -n hobbyfarm --set image.tag=v0.1.0-rc0  > /dev/null 2>&1

# patches
kubectl patch role -n hobbyfarm hf-provisioner-digitalocean --type='json' -p='[{"op": "replace", "path": "/rules/2/resources", "value":["secrets","configmaps"]}]'  > /dev/null 2>&1
kubectl patch role -n hobbyfarm vmclaimsvc --type='json' -p='[{"op": "replace", "path": "/rules/1/resources", "value":["virtualmachineclaims","virtualmachineclaims/status","virtualmachines"]}]'  > /dev/null 2>&1

echo -e "$GREEN" "ok" "$NO_COLOR"

echo -e -n " - adding settings "
### add users
kubectl apply -f settings.yaml > /dev/null 2>&1
kubectl apply -f users.yaml > /dev/null 2>&1

## add content
hfcli -k ~/.kube/config -n hobbyfarm apply scenario rancher rancher_workshop/ > /dev/null 2>&1
hfcli -k ~/.kube/config -n hobbyfarm apply scenario pure pure_workshop/ > /dev/null 2>&1

############  end hobbyfarm install  ############

echo -e "$GREEN" "ok" "$NO_COLOR"
}

############################## kill ################################
#remove the vms
function kill () {

if [ $(dolist | wc -l) -ge 1 ]; then
  echo -e -n " killing hobbyfarm"
  for i in $(dolist | awk '{print $3}'); do ssh-keygen -q -R $i > /dev/null 2>&1; done
  for i in $(dolist | awk '{print $1}'); do doctl compute droplet delete --force $i; done
  for i in $(doctl compute domain records list $domain|grep hobby |awk '{print $1}'); do doctl compute domain records delete -f $domain $i; done
  for i in $(doctl compute ssh-key list | grep hobby| awk '{ print $1 }' ); do doctl compute ssh-key delete $i --force ; done

  rm -rf ~/.kube/config 

else
  echo -e -n " no cluster found "
fi

echo -e "$GREEN" "ok" "$NO_COLOR"
}

case "$1" in
        up) up;;
        kill) kill;;
        *) echo -e "$RED" " no clue what you are trying to do..." "$NO_COLOR" ; exit 1 ;;
esac
