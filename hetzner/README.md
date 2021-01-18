# Hetzner Cloud

This small setup can be used to provision Flatcar nodes on [Hetzner Cloud](https://www.hetzner.com/cloud).

Edit the [Container Linux Config](https://kinvolk.io/docs/flatcar-container-linux/latest/container-linux-config-transpiler/configuration/) `cl/machine-mynode.yaml.tmpl` file if you like, then create the following `terraform.tfvars` with a machine `mynode`, corresponding to the Container Linux Config file name. If you add more machines, create new files for them under `cl/`.

```
cluster_name = "mycluster"
machines     = ["mynode"]
datacenter   = "fsn1-dc14"
ssh_keys     = ["ssh-rsa AA... me@mail.net"]
```

Now run Terraform (version 13) as follows:

```
export HCLOUD_TOKEN=...
terraform init
terraform apply
```

Log in via `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@IPADDRESS`.

When you make a change to `cl/machine-mynode.yaml.tmpl` and run `terraform apply` again, the instance will be replaced. Consider to use [`create_before_destroy`](https://www.terraform.io/docs/configuration/meta-arguments/lifecycle.html#syntax-and-arguments) in your final setup.
