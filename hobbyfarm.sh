### Add Helm Repo
helm repo add hobbyfarm https://hobbyfarm.github.io/hobbyfarm --force-update

### Create Namespace
kubectl create namespace hobbyfarm-system

### Create Certificates
kubectl -n hobbyfarm-system create secret generic tls-ca --from-file=/Users/clemenko/Dropbox/work/rfed.me/io/cacerts.pem 
kubectl -n hobbyfarm-system create secret tls tls-hobbyfarm-certs  --cert=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.cert --key=/Users/clemenko/Dropbox/work/rfed.me/io/star.rfed.io.key

### Install Hobbyfarm
helm upgrade -i hobbyfarm hobbyfarm/hobbyfarm -n hobbyfarm-system --set ingress.enabled=true --set ingress.tls.enabled=true --set ingress.tls.secrets.backend=tls-hobbyfarm-certs --set ingress.tls.secrets.admin=tls-hobbyfarm-certs --set ingress.tls.secrets.ui=tls-hobbyfarm-certs --set ingress.tls.secrets.shell=tls-hobbyfarm-certs --set ingress.hostnames.backend=backend.rfed.io --set ingress.hostnames.admin=admin.rfed.io --set ingress.hostnames.ui=hobbyfarm.rfed.io --set ingress.hostnames.shell=shell.refd.io --set users.admin.enabled=true --set users.admin.password='$2a$10$QkpisIWlrq/uA/BWcOX0/uYWinHcbbtbPMomY6tp3Gals0LbuFEDO'


### add users

kubectl apply -f users.yaml
