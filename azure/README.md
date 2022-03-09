# Microsoft Azure

This small setup can be used to provision Flatcar nodes on [Azure](https://azure.microsoft.com/).

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

The machine name listed in the `machines` variable is used to retrieve the corresponding [Container Linux Config](https://www.flatcar.org/docs/latest/provisioning/cl-config/). For each machine in the list, you should have a `machine-NAME.yaml.tmpl` file with a corresponding name. An example file `machine-mynode.yaml.tmpl` for `mynode` is already provided. The SSH key used there is not really necessary since we already set it as VM attribute.

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

When you make a change to `machine-mynode.yaml.tmpl` and run `terraform apply` again, the instance will be replaced. Consider using [`create_before_destroy`](https://www.terraform.io/docs/configuration/meta-arguments/lifecycle.html#syntax-and-arguments) in your final setup.
