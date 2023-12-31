#!/usr/bin/env bash
# https://github.com/zackbradys/rgs-hobbyfarm/tree/main/examples
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
#function dolist () { doctl compute droplet list --no-header|grep hobbyfarm |sort -k 2; }
function awslist () { aws ec2 describe-instances --filters Name=tag:Name,Values=clemenko_hobbyfarm --query 'Reservations[*].Instances[*].PublicIpAddress' --output text; }

################################# up ################################
function up () {

echo -e -n " building hobbyfarm vm "
# do
#doctl compute droplet create hobbyfarm --region nyc3 --image rockylinux-9-x64 --size s-8vcpu-16gb-amd --ssh-keys 30:98:4f:c5:47:c2:88:28:fe:3c:23:cd:52:49:51:01 --wait --droplet-agent=false > /dev/null 2>&1

#aws
aws ec2 run-instances --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=clemenko_hobbyfarm},{Key=KeepRunning,Value=true}]' --image-id ami-08f362c39d03a4eb5 --count 1 --instance-type m7a.4xlarge --key-name clemenko --security-group-ids sg-0c87eb1835fdbb24f --subnet-id subnet-0ca6bea3c0d18b6f3 --user-data $'#!/bin/bash\necho "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA26evmemRbhTtjV9szD9SwcFW9VOD38jDuJmyYYdqoqIltDkpUqDa/V1jxLSyrizhOHrlJtUOj790cxrvInaBNP7nHIO+GwC9VH8wFi4KG/TFj3K8SfNZ24QoUY12rLiHR6hRxcT4aUGnqFHGv2WTqsW2sxz03z+W1qeMqWYJOUfkqKKs2jiz42U+0Kp9BxsFBlai/WAXrQsYC8CcpQSRKdggOMQf04CqqhXzt5Q4Cmago+Fr7HcvEnPDAaNcVtfS5DYLERcX2OVgWT3RBWhDIjD8vYCMBBCy2QUrc4ZhKZfkF9aemjnKLfLcbdpMfb+r7NwJsVQSPKcjYAJOckE8RQ== clemenko@clemenko.local" > /root/.ssh/authorized_keys' > /dev/null 2>&1

aws ec2 wait instance-running --filters Name=tag:Name,Values=clemenko_hobbyfarm

echo -e "$GREEN" "ok" "$NO_COLOR"

#check for SSH
echo -e -n " checking for ssh "

server=$(awslist)

until [ $(ssh -o ConnectTimeout=1 root@$server 'exit' 2>&1 | grep 'timed out\|refused' | wc -l) = 0 ]; do echo -e -n "." ; sleep 5; done
echo -e "$GREEN" "ok" "$NO_COLOR"

#update DNS
echo -e -n " updating dns"
doctl compute domain records create $domain --record-type A --record-name hobbyfarm --record-ttl 60 --record-data $server > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name hobby-admin --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name hobby-backend --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
doctl compute domain records create $domain --record-type CNAME --record-name hobby-shell --record-ttl 60 --record-data hobbyfarm.$domain. > /dev/null 2>&1
echo -e "$GREEN" "ok" "$NO_COLOR"

sleep 10

echo -e -n " installing k3s"
k3sup install --ip $server --user root --cluster --k3s-extra-args '' --local-path ~/.kube/config > /dev/null 2>&1
echo -e "$GREEN" "ok" "$NO_COLOR"

echo -e -n " - k3s active "
sleep 5
until [ $(kubectl get node|grep NotReady|wc -l) = 0 ]; do echo -e -n "."; sleep 2; done
echo -e "$GREEN" "ok" "$NO_COLOR"


############   hobbyfarm install   ############
### Add Helm Repo
echo -e -n " - deploying hobbyfarm "
helm repo add hobbyfarm https://hobbyfarm.github.io/hobbyfarm --force-update > /dev/null 2>&1

### Create Namespace
kubectl create namespace hobbyfarm > /dev/null 2>&1

### Create Certificates
kubectl -n hobbyfarm create secret generic tls-ca --from-file=/Users/clemenko/Dropbox/work/rfed.me/io/cacerts.pem  > /dev/null 2>&1
kubectl -n hobbyfarm create secret tls tls-hobbyfarm-certs  --cert=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.cert --key=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.key > /dev/null 2>&1

### adding logos
kubectl create configmap rgs-logo -n hobbyfarm --from-file=rancher-labs-stacked-color.svg=RGS_Vertical.svg > /dev/null 2>&1

### add creds - set the variables on the shell
# set export ACCESS_KEY=...
# set export SECRET_KEY=...
# set export DO_TOKEN=...
kubectl create secret -n hobbyfarm generic aws-creds --from-literal=access_key=$HF_ACCESS_KEY --from-literal=secret_key=$HF_SECRET_KEY > /dev/null 2>&1
kubectl create secret -n hobbyfarm generic do-token --from-literal=token=$DO_TOKEN > /dev/null 2>&1

### Install Hobbyfarm
helm upgrade -i hobbyfarm hobbyfarm/hobbyfarm -n hobbyfarm --set ingress.enabled=true --set ingress.tls.enabled=true --set ingress.tls.secrets.backend=tls-hobbyfarm-certs --set ingress.tls.secrets.admin=tls-hobbyfarm-certs --set ingress.tls.secrets.ui=tls-hobbyfarm-certs --set ingress.tls.secrets.shell=tls-hobbyfarm-certs --set ingress.hostnames.backend=hobby-backend.$domain --set ingress.hostnames.admin=hobby-admin.$domain --set ingress.hostnames.ui=hobbyfarm.$domain --set ingress.hostnames.shell=hobby-shell.$domain  --set ui.config.title="RGS - Workshop"  --set ui.config.login.customlogo=rgs-logo --set terraform.enabled=true --set shell.replicas=3  --set admin.config.title="RGS - Workshop"  --set admin.config.login.customlogo=rgs-logo  > /dev/null 2>&1

#--set users.admin.enabled=true --set users.admin.password='$2a$10$QkpisIWlrq/uA/BWcOX0/uYWinHcbbtbPMomY6tp3Gals0LbuFEDO'

# https://github.com/hobbyfarm/hf-provisioner-digitalocean
# --set gargantua.image=ebauman/gargantua:pr-154-3
# helm install hf-provisioner-digitalocean provisioner-digitalocean/chart/hf-provisioner-digitalocean --namespace hobbyfarm > /dev/null 2>&1

sleep 60

echo -e "$GREEN" "ok" "$NO_COLOR"

echo -e -n " - adding settings "
### add users
kubectl apply -f settings.yaml > /dev/null 2>&1

## add content
hfcli -k ~/.kube/config -n hobbyfarm apply scenario nsg-workshop nsg-workshop/ > /dev/null 2>&1

############  end hobbyfarm install  ############

echo -e "$GREEN" "ok" "$NO_COLOR"
}

############################## kill ################################
#remove the vms
function kill () {

# for do
#if [ ! -z $(dolist | awk '{printf $3","}' | sed 's/,$//') ]; then
#  echo -e -n " killing it all "
#  for i in $(dolist | awk '{print $2}'); do doctl compute droplet delete --force $i; done
#  for i in $(dolist | awk '{print $3}'); do ssh-keygen -q -R $i > /dev/null 2>&1; done
#  for i in $(doctl compute domain records list $domain|grep hobbyfarm |awk '{print $1}'); do doctl compute domain records delete -f $domain $i; done
#  until [ $(dolist | wc -l | sed 's/ //g') == 0 ]; do echo -e -n "."; sleep 2; done

# for aws
if [ $(awslist | wc -l) = 1 ]; then
  echo -e -n " killing hobbyfarm"
#  for i in $(dolist | awk '{print $2}'); do doctl compute droplet delete --force $i; done
  aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters Name=tag:Name,Values=clemenko_hobbyfarm --query 'Reservations[*].Instances[*].InstanceId' --output text) > /dev/null 2>&1
  for i in $(awslist); do ssh-keygen -q -R $i > /dev/null 2>&1; done
  for i in $(doctl compute domain records list $domain|grep hobby |awk '{print $1}'); do doctl compute domain records delete -f $domain $i; done

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
