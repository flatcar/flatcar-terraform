# Flatcar Provisioning Automation for Linode (Akamai)

This repository provides tools to automate Kubernetes provisioning on [Linode (Akamai)][linode] using [OpenTofu][opentofu] and Flatcar via the Systemd sysext approach: https://www.flatcar.org/docs/latest/container-runtimes/getting-started-with-kubernetes/#deploy-a-kubernetes-cluster-with-flatcar

:warning: This is really for demo purposes but it can serve as a foundation (for example do not pass the admin configuration through HTTP for workers to join) :warning:

## Features

- Minimal configuration required (demo deployment works with default settings w/o any customisation, just run `tofu apply`!).
- Deploy one or multiple workers.

## Prerequisites

1. Linode (Akamai) access token: `token`
2. A public SSH key to install on the control plane

## HowTo

This will create a server in 'us-ord' using a medium instance size for the control plane and small instance sizes for the three workers.
See "Customisation" below for advanced settings.

1. Clone the repo and `cd akamai`
2. Download Flatcar image (this is required while Flatcar is not directly available on Linode). For latest: `wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_akamai_image.bin.gz`
3. Add API token and a SSH key in a `terraform.tfvars` file, expected credentials name can be found in `provider.tf`
4. Run
   ```bash
   tofu init
   ```
5. Plan and apply.
   ```bash
   tofu plan
   tofu apply
   ```

OpenTofu will print the control plane information (ipv4) after deployment concluded. You can now easily fetch the kubernetes `admin` configuration via a secure channel:

_NOTE_: You need to temporary allow SSH connection on the control-plane firewall to fetch the admin configuration.

```
$ scp core@<IP from the output>:/home/core/.kube/config ~/.kube/config
$ kubectl get nodes
NAME                STATUS     ROLES           AGE     VERSION
control-plane-slx   NotReady   control-plane   4m13s   v1.32.1
worker-slx-0        NotReady   <none>          4m2s    v1.32.1
worker-slx-1        NotReady   <none>          2m9s    v1.32.1
worker-slx-2        NotReady   <none>          2m11s   v1.32.1
```

From now, you can operate the Kubernetes cluster as usual (deploy CNI, deploy workloads, etc.)

_NOTE_:
* This example will update Kubernetes for patch releases: to control node reboot, [`kured`](https://github.com/kubereboot/kured) needs to be installed and configured. For minor and major updates, a manual intervention might be required
* Control plane IP address can be found at any moment after deployment by running `tofu output`
* If you update server configuration(s) in `server-configs` and re-run `tofu apply`, the instance will be **replaced**.
Consider adding [`create_before_destroy`](https://opentofu.org/docs/language/meta-arguments/lifecycle/#syntax-and-arguments) to the `linode_instance` resource to avoid services becoming unavailable during reprovisioning.

### Customisation

The provisioning automation can be customised via settings in `terraform.tfvars`:
  - `ssh_keys`: SSH public keys to add to core user's `authorized_keys` (needed for fetching the Kubernetes configuration)
  - `api_version`: Linode API version
  - `token`: Linode API token
  - `control_plane_type`: Which instance type used for deploying the control plane 
  - `worker_type`: Which instance type used for deploying the workers
  - `kubernetes_version`: The Kubernetes version to deploy (NOTE: It has to be released on the Flatcar sysext bakery: https://github.com/flatcar/sysext-bakery/releases/tag/latest)
  - `workers`: How many workers to deploy

[linode]: https://www.linode.com/
[butane]: https://www.flatcar.org/docs/latest/provisioning/config-transpiler/configuration/
[opentofu]: https://opentofu.org/
