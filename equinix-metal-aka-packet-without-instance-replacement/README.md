# Equinix Metal (formerly known as Packet) without instance replacement

This small setup can be used to provision Flatcar nodes on [Equinix Metal](https://metal.equinix.com/) with the instance user data (Ignition config) used for reconfiguration. The advantage is to be able to keep persistent data, keep the same IP address, and to reduce the time of re-applying a configuration change.

This setup uses `flatcar-reset` to clean the rootfs while preserving allowed paths, but you can also use the [reinstall](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/equinix_metal_device#reinstall) option and drop `reprovision-helper` at the expense of losing all rootfs data.

Edit the [Container Linux Config](https://kinvolk.io/docs/flatcar-container-linux/latest/container-linux-config-transpiler/configuration/) `cl/machine-mynode.yaml.tmpl` file if you like, then create the following `terraform.tfvars` with a machine `mynode`, corresponding to the Container Linux Config file name. If you add more machines, create new files for them under `cl/`.

```
cluster_name = "mycluster"
machines     = ["mynode"]
plan         = "t1.small.x86"
facilities   = ["sjc1"]
project_id   = "1...-2...-3...-4...-5..."
ssh_keys     = ["ssh-rsa AA... me@mail.net"]
```

It is recommended to register your SSH key in the Equinix Metal Project to use the out-of-band console. Since Flatcar will fetch this key, too, you can remove it from the YAML config.

Now run Terraform (version 13) as follows:

```
export METAL_AUTH_TOKEN=...
terraform init
terraform apply
```

Log in via `ssh core@IPADDRESS` (maybe add `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0`).

When you make a change to `machine-mynode.yaml.tmpl` (e.g., `my-setting v1` to `my-setting v2` and run `terraform apply` again, the instance is just rebooted instead of recreated and the new Ignition config applied while keeping wanted data (see `KEEPPATHS` setting) and discarding the rest.

We can run this command to compare the values of `/etc/config-side-effect` and `/mydata/data` before and after the run. We should see that `/etc/config-side-effect` changes while `/mydata/data` stays the same.

```
ssh core@IPADDRESS "head /etc/config-side-effect /mydata/data"
```
