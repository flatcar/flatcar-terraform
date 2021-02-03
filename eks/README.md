# Using Flatcar Container Linux for EKS worker nodes

This directory contains subdirectories with different examples of how you can use terraform to launch EKS clusters that run Flatcar on the worker nodes.

* [Simple example](simple) is the most basic setup. It uses Flatcar Container Linux Pro, which is optimized for AWS and EKS, to setup an EKS cluster with Flatcar worker nodes.
* [Simple example with bastion](simple-with-bastion) is similar to the simple example, but also includes a bastion machine that facilitates connecting through SSH into the workers, in case you want to debug or troubleshoot by accessing the nodes directly.
* [Complex example](complex) is a more complex setup that uses Flatcar Container Linux, injecting the necessary user data using Ignition configs.

All examples use [terraform](terraform.io/) to create and configure the necessary resources.
