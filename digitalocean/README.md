# DigitalOcean

This small setup can be used to provision Flatcar nodes on [DigitalOcean](https://www.digitalocean.com/).

Create a `terraform.tfvars` file that lists your preferences. Like this one:

```
cluster_name           = "mycluster"
machines               = ["mynode"]
datacenter             = "nyc3"
ssh_keys               = ["ssh-rsa AA... me@mail.net"]
flatcar_stable_version = "x.y.z"
```

You can resolve the latest Flatcar Stable version with this shell command:

```
(source <(curl -sSfL https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt); echo "${FLATCAR_VERSION_ID}")
```

The machine name listed in the `machines` variable is used to retrieve the corresponding [Container Linux Config](https://kinvolk.io/docs/flatcar-container-linux/latest/container-linux-config-transpiler/configuration/). For each machine in the list, you should have a `machine-NAME.yaml.tmpl` file with a corresponding name. An example file `machine-mynode.yaml.tmpl` for `mynode` is already provided.

Now run Terraform (version 13) as follows:

```
export DIGITALOCEAN_TOKEN=...
terraform init
terraform apply
```

When terraform is done running, it will print the IP addresses of the machines created. Log in via `ssh core@IPADDRESS` (maybe add `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null`).

When you make a change to `machine-mynode.yaml.tmpl` and run `terraform apply` again, the instance will be replaced. Consider using [`create_before_destroy`](https://www.terraform.io/docs/configuration/meta-arguments/lifecycle.html#syntax-and-arguments) in your final setup.
