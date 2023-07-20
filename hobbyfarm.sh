#!/usr/bin/env bash
# https://github.com/zackbradys/rgs-hobbyfarm/tree/main/examples
# script to build a single vm with k3s and hobby-farm

password=Pa22word
#size=s-8vcpu-16gb-amd
size=s-4vcpu-8gb-amd 
key=30:98:4f:c5:47:c2:88:28:fe:3c:23:cd:52:49:51:01
domain=rfed.io
image=rockylinux-9-x64

######  NO MOAR EDITS #######
export RED='\x1b[0;31m'
export GREEN='\x1b[32m'
export BLUE='\x1b[34m'
export YELLOW='\x1b[33m'
export NO_COLOR='\x1b[0m'
export PDSH_RCMD_TYPE=ssh

# builds a vm list
function dolist () { doctl compute droplet list --no-header|grep hobbyfarm |sort -k 2; }

################################# up ################################
function up () {

echo -e -n " building hobbyfarm vm"
doctl compute droplet create hobbyfarm --region nyc3 --image $image --size $size --ssh-keys $key --wait --droplet-agent=false > /dev/null 2>&1
echo -e "$GREEN" "ok" "$NO_COLOR"

#check for SSH
echo -e -n " checking for ssh "

server=$(dolist | awk '{print $3}')
until [ $(ssh -o ConnectTimeout=1 root@$server 'exit' 2>&1 | grep 'timed out\|refused' | wc -l) = 0 ]; do echo -e -n "." ; sleep 5; done
echo -e "$GREEN" "ok" "$NO_COLOR"

#update DNS
echo -e -n " updating dns"
doctl compute domain records create $domain --record-type A --record-name hobbyfarm --record-ttl 60 --record-data $server > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name "*" --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
echo -e "$GREEN" "ok" "$NO_COLOR"

sleep 10

echo -e -n " installing k3s"
k3sup install --ip $server --user root --cluster --k3s-extra-args '' --local-path ~/.kube/config > /dev/null 2>&1
echo -e "$GREEN" "ok" "$NO_COLOR"

echo -e -n " - k3s active "
sleep 5
until [ $(kubectl get node|grep NotReady|wc -l) = 0 ]; do echo -e -n "."; sleep 2; done
echo -e "$GREEN" "ok" "$NO_COLOR"


### Add Helm Repo
echo -e -n " - deploying hobbyfarm "
helm repo add hobbyfarm https://hobbyfarm.github.io/hobbyfarm --force-update > /dev/null 2>&1

### Create Namespace
kubectl create namespace hobbyfarm > /dev/null 2>&1

### Create Certificates
kubectl -n hobbyfarm create secret generic tls-ca --from-file=/Users/clemenko/Dropbox/work/rfed.me/io/cacerts.pem  > /dev/null 2>&1
kubectl -n hobbyfarm create secret tls tls-hobbyfarm-certs  --cert=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.cert --key=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.key > /dev/null 2>&1

### adding logos
kubectl create configmap rgs-logo -n hobbyfarm --from-file=rancher-labs-stacked-color.svg=rfed-logo-stacked.svg > /dev/null 2>&1

### and aws creds - set the variables on the shell
# set export ACCESS_KEY=...
# set export SECRET_KEY=...
kubectl create secret -n hobbyfarm generic aws-creds --from-literal=access_key=$ACCESS_KEY --from-literal=secret_key=$SECRET_KEY > /dev/null 2>&1

kubectl create secret -n hobbyfarm generic do-token --from-literal=token=$DO_TOKEN > /dev/null 2>&1

exit

### Install Hobbyfarm
helm upgrade -i hobbyfarm hobbyfarm/hobbyfarm -n hobbyfarm --set ingress.enabled=true --set ingress.tls.enabled=true --set ingress.tls.secrets.backend=tls-hobbyfarm-certs --set ingress.tls.secrets.admin=tls-hobbyfarm-certs --set ingress.tls.secrets.ui=tls-hobbyfarm-certs --set ingress.tls.secrets.shell=tls-hobbyfarm-certs --set ingress.hostnames.backend=backend.rfed.io --set ingress.hostnames.admin=hobby-admin.rfed.io --set ingress.hostnames.ui=hobbyfarm.rfed.io --set ingress.hostnames.shell=hobby-shell.rfed.io  --set ui.config.title="RGS - Workshop"  --set ui.config.login.customlogo=rgs-logo --set terraform.enabled=true --set shell.replicas=3 --set gargantua.image=ebauman/gargantua:pr-154-3 > /dev/null 2>&1

#--set users.admin.enabled=true --set users.admin.password='$2a$10$QkpisIWlrq/uA/BWcOX0/uYWinHcbbtbPMomY6tp3Gals0LbuFEDO'

# https://github.com/hobbyfarm/hf-provisioner-digitalocean

# helm install hf-provisioner-digitalocean ./chart/hf-provisioner-digitalocean --namespace hobbyfarm

sleep 30

echo -e "$GREEN" "ok" "$NO_COLOR"

echo -e -n " - adding settings "
### add users
kubectl apply -f settings.yaml > /dev/null 2>&1

echo -e "$GREEN" "ok" "$NO_COLOR"
}

############################## kill ################################
#remove the vms
function kill () {

if [ ! -z $(dolist | awk '{printf $3","}' | sed 's/,$//') ]; then
  echo -e -n " killing it all "
  for i in $(dolist | awk '{print $2}'); do doctl compute droplet delete --force $i; done
  for i in $(dolist | awk '{print $3}'); do ssh-keygen -q -R $i > /dev/null 2>&1; done
  for i in $(doctl compute domain records list $domain|grep hobbyfarm |awk '{print $1}'); do doctl compute domain records delete -f $domain $i; done
  until [ $(dolist | wc -l | sed 's/ //g') == 0 ]; do echo -e -n "."; sleep 2; done

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