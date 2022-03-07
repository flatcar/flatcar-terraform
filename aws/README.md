# AWS EC2

This small setup can be used to provision Flatcar nodes on [AWS EC2](https://aws.amazon.com/ec2/).

Create a `terraform.tfvars` file that lists your preferences. Like this one:

```
cluster_name            = "mycluster"
machines                = ["mynode"]
ssh_keys                = ["ssh-rsa AA... me@mail.net"]
```

The machine name listed in the `machines` variable is used to retrieve the corresponding [Container Linux Config](https://www.flatcar.org/docs/latest/provisioning/cl-config/). For each machine in the list, you should have a `machine-NAME.yaml.tmpl` file with a corresponding name. An example file `machine-mynode.yaml.tmpl` for `mynode` is already provided. The SSH key used there is not really necessary since we already set it as VM attribute.

Now run Terraform (version 13) as follows:

```
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
terraform init
terraform apply
```

On the first run you will get an error with a URL where you have to confirm that you agree with the terms and conditions of the Marketplace image.

When terraform is done running, it will print the IP addresses of the machines created. Log in via `ssh core@IPADDRESS` (maybe add `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null`).

When you make a change to `machine-mynode.yaml.tmpl` and run `terraform apply` again, the instance will be replaced. Consider using [`create_before_destroy`](https://www.terraform.io/docs/configuration/meta-arguments/lifecycle.html#syntax-and-arguments) in your final setup.
