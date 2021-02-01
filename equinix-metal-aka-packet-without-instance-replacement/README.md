# Equinix Metal (formerly known as Packet) without instance replacement

This small setup can be used to provision Flatcar nodes on [Equinix Metal](https://metal.equinix.com/) with the instance user data (Ignition config) of the node on AWS S3. It is an experiment to show how to circumvent instance replacement when updating the node user data by replacing just the AWS S3 contents and telling Ignition to rerun on the node. This only works when the Ignition config contains a directive to reformat the root filesystem, so that no old state is kept. The advantage is to be able to keep persistent data on another partition, keep the same IP address, and to reduce the time of re-applying a configuration change. Drawbacks are changing SSH host keys and a changing `/etc/machine-id` value. One also has to treat the `.*.init` files like the Terraform state file.

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
export AWS_DEFAULT_REGION=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
terraform init
terraform apply
```

Log in via `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@IPADDRESS`.

Make a change to `cl/machine-mynode.yaml.tmpl` and run `terraform apply` again, seeing how the node is just rebooted and the new config applied.

WARNING: Do not put secrets into `cl/machine-mynode.yaml.tmpl` because for this proof-of-concept the AWS S3 bucket is publicly accessible.

It is recommended to register your SSH key in the Equinix Metal Project to use the out-of-band console. Since Flatcar will fetch this key, too, you can remove it from the YAML config.
