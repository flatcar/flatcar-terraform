# Using Flatcar Container Linux for EKS worker nodes

This terraform example creates an EKS cluster with workers that run Flatcar Container Linux.

To run this successfully, you'll need to use AWS keys that can create an EKS cluster (with at least [these permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md) enabled). And have the authentication to that account setup in [any of the supported ways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication).

You'll also need to install the [terraform ct provider](https://github.com/poseidon/terraform-provider-ct), which does the transpiling of Container Linux Configs into Ignition rules.

## Customization options

Typical customization values (region, number of workers, instance type, etc) are split into the `variables.tf` file.

To create the cluster, this example uses the [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module. Check out the module documentation if you want to customize other values.

The EKS worker nodes are not accessible from the outside. To allow for experimentation and debugging, this example creates a bastion node. It's possible to connect via SSH to the bastion node, and then connect to the worker nodes through it. A production setup shouldn't use this bastion node, that snippet can just be removed from the rules.

## Accessing the cluster

Once the cluster is setup, you'll need [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) to connect to it using `kubectl`, passing the generated `kubeconfig_<cluster-name>` file.
