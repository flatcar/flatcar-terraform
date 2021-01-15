# Equinix Metal (formerly known as Packet)

This small setup can be used to provision Flatcar nodes on [Equinix Metal](https://metal.equinix.com/).

Edit the [Container Linux Config](https://kinvolk.io/docs/flatcar-container-linux/latest/container-linux-config-transpiler/configuration/) `cl/machine-mynode.yaml.tmpl` file if you like, then create the following `terraform.tfvars` with a machine `mynode`, corresponding to the Container Linux Config file name. If you add more machines, create new files for them under `cl/`.

```
cluster_name = "mycluster"
machines     = ["mynode"]
plan         = "t1.small.x86"
facilities   = ["sjc1"]
project_id   = "1...-2...-3...-4...-5..."
ssh_keys     = ["ssh-rsa AA... me@mail.net"]
```

Now run Terraform (version 13) as follows:

```
export PACKET_AUTH_TOKEN=...
terraform init
terraform apply
```

Log in via `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@IPADDRESS`.

When you make a change to `cl/machine-mynode.yaml.tmpl` and run `terraform apply` again, the instance will be replaced. Consider to use [`create_before_destroy`](https://www.terraform.io/docs/configuration/meta-arguments/lifecycle.html#syntax-and-arguments) in your final setup.

It is recommended to register your SSH key in the Equinix Metal Project to use the out-of-band console. Since Flatcar will fetch this key, too, you can remove it from the YAML config.
