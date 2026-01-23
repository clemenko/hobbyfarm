# hf-provisioner-digitalocean

A 3rd party provisioner for HobbyFarm that provisions VMs into DigitalOcean

## Status

Alpha software

## Prerequisites

1. HobbyFarm Installation

As of this writing you need to be running a version of Gargantua that 
tracks changes that are not yet on `main`. Use `hobbyfarm/gargantua:v.3.0.1-rc0`
for now, until the changes that allow this provider to function are
in `main`.

## Installation

Change `$NAMESPACE` to be the namespace in which your target installation of HobbyFarm is located.
This provisioner is namespaced so that multiple can be installed in the same cluster, thus
you must install this in the same naespace as the HobbyFarm you wish to "enable" with this functionality.

```
git clone https://github.com/hobbyfarm/hf-provisioner-digitalocean
cd hf-provisioner-digitalocean
helm install hf-provisioner-digitalocean ./chart/hf-provisioner-digitalocean -n $NAMESPACE
```

## Usage

1. Add an annotation to your Environment of `hobbyfarm.io/provisioner: digitalocean`
2. Add the following required values to `environment_specifics` and 
`template_mapping` on your Environment:
```yaml
...
spec:
  environment_specifics:
    region: nyc1 # any valid digitalocean region slug
    token-secret: do_secret # a secret with key of 'token' and value
    token: dop_v1_... # if you wanna put your secret in plaintext (dumb)
  template_mapping:
    your_template:
      image: ubuntu-20-04-x64 # any valid digitalocean image slug
      size: s-1vcpu-512mb-10gb # any valid digitalocean size slug
```
3. Optionally add any of the following config items to `environment_specifics` 
or `template_mapping`:
```yaml
backups: "false" # or "true"
ipv6: "false" # or "true" (not tested, YMMV)
monitoring: "false" # or "true" (not sure what this does)
private_networking: "false" # or "true" (not tested, YMMV)

# must be plaintext, not to exceed 64KiB (says DO docs)
user_data: "#cloud-config ..."
```

4. Provision VMs as you normally would.

## Theory

Two CRDs get created - Droplets and Keys. Keys track SSH Keys for Droplets. 

When a VM is created in Kubernetes, and its provider is set to `digitalocean`, 
this provider does the following:
1. Attaches a finalizer to the VM to make sure we can clean up when the VM deletes
2. Creates a secret with a newly generated SSH key in it
3. Creates a `Key` object with a DigitalOcean `KeyCreateRequest` in it
4. Creates a `Droplet` object with a DigitalOcean `DropletCreateRequest` in it
5. Picks up the `Key` object and calls DO's API to create the SSH Key
   6. puts the response in the `Key.Status` object
   7. modifies `VirtualMachine.Spec.SecretName` to point to where SSH key is
7. Picks up the `Droplet` object and calls DO's API to create the Droplet
   8. puts the response in the `Droplet.Status` object
9. Attaches finalizers to `Key` and `Droplet` objects ensuring they are
cleaned up in DigitalOcean before deleting them in K8s
10. Periodically re-syncs the `Droplet` object with DigitalOcean to get updates
about things like IPs, droplet status, etc.
11. Writes appropriate status items to `VirtualMachine.Status` so HobbyFarm 
can utilize the new VM.

May have missed something in the above, but that's the gist of it

## Contributing

Feel encouraged. Reach here on issues or in rancher users slack, #hobbyfarm
