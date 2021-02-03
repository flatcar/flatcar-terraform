# Using Flatcar Container Linux Pro for EKS worker nodes - with Bastion

This terraform example creates an EKS cluster with workers that run Flatcar Container Linux Pro.

To run this successfully, you'll need to use AWS keys that can create an EKS cluster (with at least [these permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md) enabled). And have the authentication to that account setup in [any of the supported ways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication).

## Subscribing to the Pro offer

This example uses the Flatcar Container Linux Pro for AWS offer, which comes with AWS specific optimization and simplified EKS integration. To launch the workers, you'll need to [subscribe to the Pro offer](https://aws.amazon.com/marketplace/pp/B08QLXLWV5) with your AWS account.

This only needs to be done once per account. After subscribing, you will be able to launch as many clusters and workers as you need using the Flatcar Container Linux Pro offer. You will be charged an hourly rate on top of the infrastructure cost, according to the [pricing scheme](https://aws.amazon.com/marketplace/pp/B08QLXLWV5#pdp-pricing). You only get charged for the hours your instances are running.

## Customization options

Typical customization values (region, number of workers, instance type, etc) are split into the `variables.tf` file. You can modify these values by creating a `terraform.tfvars` file, or passing them in the command-line (`-var name=value`). The only mandatory variable that you need to set is `ssh_public_key` which should hold the contents of the public SSH key that you want to use to SSH into the bastion and the workers.

To create the cluster, this example uses the [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module. Check out the module documentation if you want to customize other values.

## Setting up the cluster

Once you've set the right environment variables and subscribed to the Flatcar Container Linux Pro offer, you can create the cluster by running:

```
terraform init
terraform apply
```

This will do a number of validations and if everything is ok will prompt you to confirm that you want those resources to be created.

## Accessing the cluster

The EKS worker nodes are not accessible from the outside. To allow for experimentation and debugging, this example creates a bastion node. It's possible to connect via SSH to the bastion node, and then connect to the worker nodes through it (by using the `-J` or `-A` flags). Please note that a production setup shouldn't use this bastion node.

To interact with the Kubernetes cluster, use the generated `kubeconfig` file. To do that, you'll need [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) to connect to it using `kubectl`, passing the generated `kubeconfig_<cluster-name>` file. As in this example:

```
$ kubectl --kubeconfig kubeconfig_flatcar-cluster get nodes
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-1-125.us-east-2.compute.internal   Ready    <none>   20s   v1.18.9-eks-d1db3c
ip-10-0-3-208.us-east-2.compute.internal   Ready    <none>   25s   v1.18.9-eks-d1db3c
```

Please note that it might take a minute for the cluster to be ready after terraform is done setting it up.

## Destroying the cluster and all associated resources

The cluster as set up will use compute resources that will be billed to your account.  Once you're done using them, you should destroy them, to avoid unnecessary charges.  To do that, you can run:

```
terraform destroy
```
