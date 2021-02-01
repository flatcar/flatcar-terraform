# Local QEMU VM cluster with libvirt without instance replacement

This small setup can be used to provision Flatcar nodes on your Linux laptop with the [libvirt provider](https://github.com/dmacvicar/terraform-provider-libvirt/).
A new disk volume pool will be created in `/var/tmp` as precaution to not modify the base image by accident. In contrast to the other libvirt setup, the instance user data will be updated by replacing the file contents and forcing QEMU to exit and start again.
It is an experiment to show how to circumvent instance replacement when updating the node user data by replacing just the user-data contents and telling Ignition to rerun on the node. This only works when the Ignition config contains a directive to reformat the root filesystem, so that no old state is kept. The advantage is to be able to keep persistent data on another partition, keep the same IP address, and to reduce the time of re-applying a configuration change. Drawbacks are changing SSH host keys. One also has to treat the `.*.init` files like the Terraform state file.


First, prepare the base image and make sure you don't boot it via the [flatcar_production_qemu.sh](https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu.sh) script or similar:
```
cd ~/Downloads
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2
bunzip2 flatcar_production_qemu_image.img.bz2
mv flatcar_production_qemu_image-libvirt-import.img
# optional, increase the image by 5 GB:
qemu-img resize flatcar_production_qemu_image-libvirt-import.img +5G
```

It will only be used once for the import and can be deleted afterwards even when new VMs are added.

Edit the [Container Linux Config](https://kinvolk.io/docs/flatcar-container-linux/latest/container-linux-config-transpiler/configuration/) `cl/machine-mynode.yaml.tmpl` file if you like, then create the following `terraform.tfvars` with a machine `mynode`, corresponding to the Container Linux Config file name. If you add more machines, create new files for them under `cl/`.

```
base_image     = "file:///home/myself/Downloads/flatcar_production_qemu_image-libvirt-import.img"
cluster_name  = "mycluster"
machines     = ["mynode"]
virtual_memory = 768
ssh_keys     = ["ssh-rsa AA... me@mail.net"]
```

Now run Terraform (version 13) as follows:

```
terraform init
terraform apply
```

View the VMs in `virt-manager` where you can see the VGA console.
Log in via `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@IPADDRESS`.

Make a change to `cl/machine-mynode.yaml.tmpl` and run `terraform apply` again, seeing how the node is just rebooted and the new config applied.
