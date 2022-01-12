# Microsoft Azure without instance replacement

This small setup can be used to provision Flatcar nodes on [Azure](https://azure.microsoft.com/) with the instance user data (Ignition config) of the node on Azure Blob Storage.
It is an experiment to show how to circumvent instance replacement when updating the node user data by replacing just the Blob Storage contents and telling Ignition to rerun on the node.
This only works when the Ignition config contains a directive to reformat the root filesystem, so that no old state is kept.
The advantage is to be able to keep persistent data on another partition, keep the same IP address, and to reduce the time of re-applying a configuration change.
Drawbacks are changing SSH host keys and a changing `/etc/machine-id` value, and due to a current limitation an additional reboot when provisioning the first time.

Create a `terraform.tfvars` file that lists your preferences. Like this one:

```
cluster_name            = "mycluster"
machines                = ["mynode"]
ssh_keys                = ["ssh-rsa AA... me@mail.net"]
flatcar_stable_version  = "x.y.z"
```

You can resolve the latest Flatcar Stable version with this shell command:

```
curl -sSfL https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt | grep -m 1 FLATCAR_VERSION_ID= | cut -d = -f 2
```

The machine name listed in the `machines` variable is used to retrieve the corresponding [Container Linux Config](https://kinvolk.io/docs/flatcar-container-linux/latest/container-linux-config-transpiler/configuration/). For each machine in the list, you should have a `machine-NAME.yaml.tmpl` file with a corresponding name. An example file `machine-mynode.yaml.tmpl` for `mynode` is already provided.

First find your subscription ID, then create a service account for Terraform and note the tenant ID, client (app) ID, client (password) secret:

```
az login
az account set --subscription <azure_subscription_id>
az ad sp create-for-rbac --name <service_principal_name> --role Contributor
{
  "appId": "...",
  "displayName": "<service_principal_name>",
  "password": "...",
  "tenant": "..."
}
```
Make sure you have AZ CLI version 2.32.0 if you get the error `Values of identifierUris property must use a verified domain of the organization or its subdomain`.
AZ CLI installation docs are [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions).

Before you run Terraform, accept the image terms:

```
az vm image terms accept --urn kinvolk:flatcar-container-linux:stable:<flatcar_stable_version>
```

Now run Terraform (version 13) as follows:

```
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
terraform init
terraform apply
```

When terraform is done running, it will print the IP addresses of the machines created. Log in via `ssh core@IPADDRESS` (maybe add `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null`).

When you make a change to `machine-mynode.yaml.tmpl` and run `terraform apply` again, the instance is just rebooted and the new config applied.
