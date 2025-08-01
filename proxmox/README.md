# Proxmox

This small examplez demo how to provision flatcar on proxmox using terraform

## Prerequisite

  - A proxmox cluster with credentials
  - `terraform`
  - `mkisofs`:
      ArchLinux: `pacman -Sy crdtools`
      Debian/Ubuntu: `apt install genisoimage`
      Mac OS: `brew install cdrtools`
      RPM/DNF based OS: `dnf install mkisofs`


## How-to

This module use the `bpg/proxmox` provider, and you configure it using environment variable [here](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#argument-reference)

```
export PROXMOX_VE_ENDPOINT=
export PROXMOX_VE_USERNAME=
export PROXMOS_VE_PASSWORD=
terraform init
terraform apply
```
