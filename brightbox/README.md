# Flatcar Provisioning Automation for Brightbox

This repository provides tools to automate Kubernetes provisioning on [Brightbox][brightbox] using [Terraform][terraform] and Flatcar via the Systemd sysext approach: https://www.flatcar.org/docs/latest/container-runtimes/getting-started-with-kubernetes/#deploy-a-kubernetes-cluster-with-flatcar

:warning: This is really for demo purposes but it can serve as a foundation (for example do not pass the admin configuration through HTTP for workers to join) :warning:

## Features

- Minimal configuration required (demo deployment works with default settings w/o any customisation, just run `terraform apply`!).
- Deploy one or multiple workers.

## Prerequisites

1. Brightbox credentials: `api_client`, `api_secret`.
2. A public SSH key to install on the control plane

## HowTo

This will create a server in 'gb1-a' using a medium instance size for the control plane and small instance sizes for the three workers.
See "Customisation" below for advanced settings.

1. Clone the repo.
2. Add credentials and a SSH key in a `terraform.tfvars` file, expected credentials name can be found in `provider.tf`
3. Run
   ```shell
   terraform init
   ```
4. Plan and apply.
   Invoke Terraform:
   ```shell
   terraform plan
   terraform apply
   ```

Terraform will print the control plane information (ipv4) after deployment concluded. You can now easily fetch the kubernetes `admin` configuration via a secure channel:

```
$ scp core@<IP from the output>:/home/core/.kube/config ~/.kube/config
$ kubectl get nodes
NAME                          STATUS     ROLES           AGE   VERSION
srv-cruzw.gb1.brightbox.com   NotReady   <none>          55s   v1.29.2
srv-fltor.gb1.brightbox.com   NotReady   control-plane   72s   v1.29.2
srv-gvzhx.gb1.brightbox.com   NotReady   <none>          59s   v1.29.2
srv-mipnf.gb1.brightbox.com   NotReady   <none>          60s   v1.29.2
```

From now, you can operate the Kubernetes cluster as usual (deploy CNI, deploy workloads, etc.)

_NOTE_:
* Server IP address can be found at any moment after deployment by running `terraform output`
* If you update server configuration(s) in `server-configs` and re-run `terraform apply`, the instance will be **replaced**.
Consider adding [`create_before_destroy`](https://www.terraform.io/docs/configuration/meta-arguments/lifecycle.html#syntax-and-arguments) to the `brightbox_server` resource in [`compute.tf`](compute.tf) to avoid services becoming unavailable during reprovisioning.

### Customisation

The provisioning automation can be customised via settings in `terraform.tfvars`:
  - `ssh_keys`: SSH public keys to add to core user's `authorized_keys` (needed for fetching the Kubernetes configuration)
  - `release_channel`: Select one of "lts", "stable", "beta", or "alpha".
    Read more about channels [here](https://www.flatcar.org/releases).
  - `flatcar_version`: Select the desired Flatcar version for the given channel (default to "current", which is the latest).
  - `zone`: Where to deploy servers
  - `control_plane_type`: Which instance type used for deploying the controle plane
  - `worker_type`: Which instance type used for deploying the workers
  - `kubernetes_version`: The Kubernetes version to deploy (NOTE: It has to be released on the Flatcar sysext bakery: https://github.com/flatcar/sysext-bakery/releases/tag/latest)
  - `workers`: How many workers to deploy

[butane]: https://www.flatcar.org/docs/latest/provisioning/config-transpiler/configuration/
[brightbox]: https://www.brightbox.com/
[terraform]: https://www.terraform.io/
