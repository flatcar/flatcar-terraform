# Flatcar Provisioning Automation for STACKIT

This repository provides tools to automate Flatcar provisioning on [STACKIT][stackit] using [Terraform][terraform-stackit].

## Features

- Minimal configuration required (demo deployment works with default settings w/o any customisation, just run `terraform apply`!).
- Deploy one or multiple servers.
- Per-server custom configuration via separate [container linux config][container-linux-config] files.

## Prerequisites
- A STACKIT project and a service account with a [service account key][stackit-sa-key]
- The OEM STACKIT or OEM OpenStack image locally
- An SSH key

`project_id`, `public_key`, `service_account_key_path`, `private_key_path` and `image_path` need to be set. You can use the `example.env` file to source all of these for Terraform at once.   

## Examples

This is a collection of examples for using Flatcar Linux on STACKIT.

| Example Directory | Type       | Description                                                                                                          |
|-------------------|------------|----------------------------------------------------------------------------------------------------------------------|
| server-basic      | Compute    | Minimal Instance: A standalone Flatcar instance with basic networking and SSH access.                                |
| server-enhanced   | Compute    | GPU & Ignition: A GPU-enabled instance using Ignition to automate NVIDIA driver installation.                        |
| cluster-basic     | Kubernetes | SKE Foundations: A STACKIT Kubernetes Engine cluster using Flatcar for the worker node pool.                         |
| cluster-enhanced  | Kubernetes | Production Ready: An SKE cluster configured with the STACKIT observability extension and custom maintenance windows. |

## HowTo

1. Clone the repo.
2. Checkout the directory of the example 
   ```shell
   cd flatcar-terraform/stackit/<example>`
   ```
3. Create and add all your required prerequisites 
   ```shell
   cp example.env secrets.env
   ```
4. Source your secrets
   ```shell
   source secrets.env
   ``` 
5. Initialize terraform
   ```shell
   terraform init
   ```
6. Adjust the example as needed (optional)
7. Invoke terraform
   ```shell
   terraform plan
   terraform apply
   ```

For the server examples, terraform will print the SSH command to connect to your server instance.  
For the Kubernetes clusters, terraform will create a kubeconfig valid for 2 hours, it will print the command to export the kubeconfig.

## Customisation

Most values are set in the `variables.tf` file for each example set up. You can adjust these as you want and expand the configuration with further options.

[container-linux-config]: https://www.flatcar.org/docs/latest/provisioning/config-transpiler/configuration/
[stackit]: https://stackit.com
[terraform-stackit]: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs
[stackit-sa-key]: https://docs.stackit.cloud/platform/access-and-identity/service-accounts/how-tos/manage-service-account-keys/#create-a-service-account-key-generate-new-key-pair
