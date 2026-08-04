# Local QEMU/KVM VM with libvirt and Terraform

This example provisions a single Flatcar Linux VM on a local Linux host using the
[libvirt Terraform provider](https://github.com/dmacvicar/terraform-provider-libvirt/)
and the [poseidon/ct provider](https://github.com/poseidon/terraform-provider-ct)
for Ignition config rendering.

Everything is contained in a single `main.tf` file — copy it, adjust the variables
at the top, and run `terraform apply`.

## Prerequisites

- A Linux host with KVM/QEMU and libvirt installed and running (`libvirtd`)
- Terraform >= 1.4
- The `default` libvirt storage pool pointing to `/var/lib/libvirt/images`
  (or adjust `pool = "default"` in the resource definitions to match your setup)

## Usage

```
terraform init
terraform plan
terraform apply
```

The domain is created in the "shut off" state and does not start automatically.
Start it and attach to the console with:

```
virsh start --console flatcar-simple
```

The base image enables autologin on the console for user `core`.
You can also log in via SSH once you have the IP address from the console output.

## Variables

All variables have sensible defaults; override them via `-var` flags or a
`terraform.tfvars` file.

| Variable             | Default           | Description                            |
|----------------------|-------------------|----------------------------------------|
| `vm_name`            | `flatcar-simple`  | Name of the VM and its disk volumes    |
| `channel`            | `stable`          | Flatcar release channel                |
| `release`            | `4459.2.3`        | Flatcar release version                |
| `memory_mib`         | `2048`            | RAM in MiB                             |
| `vcpu`               | `2`               | Number of vCPUs                        |
| `disk_capacity_bytes`| `21474836480`     | System disk size in bytes (20 GiB)     |
| `mac`                | `52:54:00:45:00:01` | MAC address for the VM's NIC         |

## Design notes

- **Immutable base image** — the downloaded Flatcar image is stored as a read-only
  base volume. Each VM's system disk is a qcow2 copy-on-write overlay on top of it,
  so the base is never modified and can be shared across many VMs.

- **Ignition via fw_cfg** — Ignition is delivered to the guest through QEMU's `fw_cfg`
  mechanism rather than a separate disk or network source. This requires
  `features { acpi = true }` on the domain, which is mandatory for q35/OVMF machines.

- **Reliable Ignition re-runs** — the libvirt provider cannot update volumes in-place.
  A `terraform_data` resource tracks all values that should trigger a fresh first boot
  (Ignition content, base image, disk size, VM name). When any of those change,
  the system disk and domain are fully replaced so Ignition always runs on a clean disk.

## Updating the Ignition config

Edit the `ct_config` block in `main.tf`, then run `terraform apply`. Terraform will
detect the change via `terraform_data.system_volume`, replace the disk and domain,
and Ignition will run on first boot of the new VM.
