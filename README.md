# flatcar-terraform
Examples of deploying Flatcar instances with Terraform

# AWS EKS worker nodes

Example Terraform setup for an EKS cluster with workers that run Flatcar Container Linux.

Follow the README instructions in the directory:

[`eks`](eks)

# Plain Flatcar instances

Example Terraform modules to provision Flatcar on two public clouds or on VMs on your laptop.

Follow the README instructions in the directories to try it out:

[`digitalocean`](digitalocean)

[`equinix-metal-aka-packet`](equinix-metal-aka-packet)

[`hetzner`](hetzner)

[`qemu-libvirt`](qemu-libvirt)

## Experiments for re-running Ignition instead of instance replacement on userdata changes

This is an experiment to show how to circumvent instance replacement when updating the node user data by telling Ignition to rerun on the node. This only works when the Ignition config contains a directive to reformat the root filesystem, so that no old state is kept. The advantage is to be able to keep persistent data on another partition, keep the same IP address, and to reduce the time of re-applying a configuration change.
Drawbacks are changing SSH host keys and a changing `/etc/machine-id` value (not for libvirt, though), and due to a current limitation an additional reboot when provisioning the first time.
A couple of workarounds are needed due to the restrictions of in-place updating the user data.

Follow the README instructions in the directories to try it out:

[`equinix-metal-aka-packet-without-instance-replacement`](equinix-metal-aka-packet-without-instance-replacement)

[`qemu-libvirt-without-instance-replacement`](qemu-libvirt-without-instance-replacement)
