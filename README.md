<div style="text-align: center">

[![Flatcar OS](https://img.shields.io/badge/Flatcar-Website-blue?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjwhLS0gR2VuZXJhdG9yOiBBZG9iZSBJbGx1c3RyYXRvciAyNi4wLjMsIFNWRyBFeHBvcnQgUGx1Zy1JbiAuIFNWRyBWZXJzaW9uOiA2LjAwIEJ1aWxkIDApICAtLT4NCjxzdmcgdmVyc2lvbj0iMS4wIiBpZD0ia2F0bWFuXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4Ig0KCSB2aWV3Qm94PSIwIDAgODAwIDYwMCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgODAwIDYwMDsiIHhtbDpzcGFjZT0icHJlc2VydmUiPg0KPHN0eWxlIHR5cGU9InRleHQvY3NzIj4NCgkuc3Qwe2ZpbGw6IzA5QkFDODt9DQo8L3N0eWxlPg0KPHBhdGggY2xhc3M9InN0MCIgZD0iTTQ0MCwxODIuOGgtMTUuOXYxNS45SDQ0MFYxODIuOHoiLz4NCjxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik00MDAuNSwzMTcuOWgtMzEuOXYxNS45aDMxLjlWMzE3Ljl6Ii8+DQo8cGF0aCBjbGFzcz0ic3QwIiBkPSJNNTQzLjgsMzE3LjlINTEydjE1LjloMzEuOVYzMTcuOXoiLz4NCjxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik02NTUuMiw0MjAuOXYtOTUuNGgtMTUuOXY5NS40aC0xNS45VjI2MmgtMzEuOVYxMzQuOEgyMDkuNFYyNjJoLTMxLjl2MTU5aC0xNS45di05NS40aC0xNnY5NS40aC0xNS45djMxLjINCgloMzEuOXYxNS44aDQ3Ljh2LTE1LjhoMTUuOXYxNS44SDI3M3YtMTUuOGgyNTQuOHYxNS44aDQ3Ljh2LTE1LjhoMTUuOXYxNS44aDQ3Ljh2LTE1LjhoMzEuOXYtMzEuMkg2NTUuMnogTTQ4Ny44LDE1MWg3OS42djMxLjgNCgloLTIzLjZ2NjMuNkg1MTJ2LTYzLjZoLTI0LjJMNDg3LjgsMTUxTDQ4Ny44LDE1MXogTTIzMywyMTQuNlYxNTFoNjMuN3YyMy41aC0zMS45djE1LjhoMzEuOXYyNC4yaC0zMS45djMxLjhIMjMzVjIxNC42eiBNMzA1LDMxNy45DQoJdjE1LjhoLTQ3Ljh2MzEuOEgzMDV2NDcuN2gtOTUuNVYyODYuMUgzMDVMMzA1LDMxNy45eiBNMzEyLjYsMjQ2LjRWMTUxaDMxLjl2NjMuNmgzMS45djMxLjhMMzEyLjYsMjQ2LjRMMzEyLjYsMjQ2LjRMMzEyLjYsMjQ2LjR6DQoJIE00NDguMywzMTcuOXY5NS40aC00Ny44di00Ny43aC0zMS45djQ3LjdoLTQ3LjhWMzAyaDE1Ljl2LTE1LjhoOTUuNVYzMDJoMTUuOUw0NDguMywzMTcuOXogTTQ0MCwyNDYuNHYtMzEuOGgtMTUuOXYzMS44aC0zMS45DQoJdi03OS41aDE1Ljl2LTE1LjhoNDcuOHYxNS44aDE1Ljl2NzkuNUg0NDB6IE01OTEuNiwzMTcuOXY0Ny43aC0xNS45djE1LjhoMTUuOXYzMS44aC00Ny44di0zMS43SDUyOHYtMTUuOGgtMTUuOXY0Ny43aC00Ny44VjI4Ni4xDQoJaDEyNy4zVjMxNy45eiIvPg0KPC9zdmc+DQo=)](https://www.flatcar.org/)
[![Matrix](https://img.shields.io/badge/Matrix-Chat%20with%20us!-green?logo=matrix)](https://app.element.io/#/room/#flatcar:matrix.org)
[![Slack](https://img.shields.io/badge/Slack-Chat%20with%20us!-4A154B?logo=slack)](https://kubernetes.slack.com/archives/C03GQ8B5XNJ)
[![Twitter Follow](https://img.shields.io/twitter/follow/flatcar?style=social)](https://x.com/flatcar)
[![Mastodon Follow](https://img.shields.io/badge/Mastodon-Follow-6364FF?logo=mastodon)](https://hachyderm.io/@flatcar)
[![Bluesky](https://img.shields.io/badge/Bluesky-Follow-0285FF?logo=bluesky)](https://bsky.app/profile/flatcar.org)

</div>

# Table of Contents

- [flatcar-terraform](#flatcar-terraform)
  - [AWS EKS worker nodes](#aws-eks-worker-nodes)
  - [Plain Flatcar instances](#plain-flatcar-instances)
    - [digitalocean](#digitalocean)
    - [equinix-metal-aka-packet](#equinix-metal-aka-packet)
    - [flatcar-terraform-hetzner](#flatcar-terraform-hetzner)
    - [qemu-libvirt](#qemu-libvirt)
    - [openstack](#openstack)
  - [Experiments for re-running Ignition instead of instance replacement on userdata changes](#experiments-for-re-running-ignition-instead-of-instance-replacement-on-userdata-changes)
    - [equinix-metal-aka-packet-without-instance-replacement](#equinix-metal-aka-packet-without-instance-replacement)
    - [qemu-libvirt-without-instance-replacement](#qemu-libvirt-without-instance-replacement)

## flatcar-terraform
Examples of deploying Flatcar instances with Terraform

:warning: This is really for demo purposes but it can serve as a foundation (for example do not pass the admin configuration through HTTP for workers to join) :warning:

## AWS EKS worker nodes

Example Terraform setup for an EKS cluster with workers that run Flatcar Container Linux.

Follow the README instructions in the directory:

### [eks](eks)
Terraform configuration for deploying an AWS EKS cluster with Flatcar Container Linux worker nodes. Includes examples for both complex and simple EKS setups, as well as a setup with a bastion host.

## Plain Flatcar instances

Example Terraform modules to provision Flatcar on two public clouds or on VMs on your laptop.

Follow the README instructions in the directories to try it out:

### [digitalocean](digitalocean)
Provision Flatcar Container Linux droplets on DigitalOcean using Terraform. Includes a sample configuration and user data template.

### [equinix-metal-aka-packet](equinix-metal-aka-packet)
Deploy Flatcar Container Linux on Equinix Metal (formerly Packet) servers. Provides templates for machine configuration and user data.

### [flatcar-terraform-hetzner](flatcar-terraform-hetzner)
Provision Flatcar Container Linux on Hetzner Cloud servers. Includes server configuration templates and example variables.

### [qemu-libvirt](qemu-libvirt)
Run Flatcar Container Linux VMs locally using QEMU and libvirt. Useful for local development and testing.

### [openstack](openstack)
Deploy Flatcar Container Linux on OpenStack infrastructure. Includes compute, network, and user data templates for OpenStack environments.

## Experiments for re-running Ignition instead of instance replacement on userdata changes

This section demonstrates how to avoid instance replacement when updating node user data by instructing Ignition to rerun on the node. This approach only works when the Ignition config includes a directive to reformat the root filesystem, ensuring no old state is retained.

**Advantages:**
- Ability to keep persistent data on another partition
- Retain the same IP address
- Reduce the time required to re-apply configuration changes

**Drawbacks:**
- SSH host keys will change
- `/etc/machine-id` value will change (except for libvirt)
- An additional reboot is required during the initial provisioning due to a current limitation

**Note:**
- Several workarounds are necessary due to the restrictions of in-place updating of user data.

Follow the README instructions in the directories to try it out:

### [equinix-metal-aka-packet-without-instance-replacement](equinix-metal-aka-packet-without-instance-replacement)
Experimental setup for Equinix Metal to re-run Ignition and avoid instance replacement on user data changes. Useful for persistent data and IP retention.

### [qemu-libvirt-without-instance-replacement](qemu-libvirt-without-instance-replacement)
Experimental setup for QEMU/libvirt to re-run Ignition without replacing the VM instance. Useful for local persistent development environments. 
