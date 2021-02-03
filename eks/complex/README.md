# Using Flatcar Container Linux for EKS worker nodes

This terraform example creates an EKS cluster with workers that run Flatcar Container Linux.

To run this successfully, you'll need to use AWS keys that can create an EKS cluster (with at least [these permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md) enabled). And have the authentication to that account setup in [any of the supported ways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication).

You'll also need to install the [terraform ct provider](https://github.com/poseidon/terraform-provider-ct), which does the transpiling of Container Linux Configs into Ignition rules.

## Subscribing to the Marketplace offer

The AMI selected by this example is the one for Flatcar Container Linux.  It's a free offer that doesn't cost extra. As this offer is delivered through the AWS Marketplace, you need to first [subscribe to the offer](https://aws.amazon.com/marketplace/pp/B08MF9S9N4) in order to use it in your account.

This only needs to be done once per account. After subscribing, you will be able to launch as many clusters and workers as you need using the Flatcar Container Linux offer.

## Customization options

Typical customization values (region, number of workers, instance type, etc) are split into the `variables.tf` file. You can modify these values by creating a `terraform.tfvars` file, or passing them in the command-line (`-var name=value`). The only mandatory variable that you need to set is `ssh_public_key` which should hold the contents of the public SSH key that you want to use to SSH into the bastion and the workers.

To create the cluster, this example uses the [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module. Check out the module documentation if you want to customize other values.

## Setting up the cluster

Once you've set the right environment variables and subscribed to the Flatcar Container Linux offer, you can create the cluster by running:

```
terraform init
terraform apply
```

This will do a number of validations and if everything is ok will prompt you to confirm that you want those resources to be created. It takes about 15 minutes for this creation to complete.

## Accessing the cluster

The EKS worker nodes are not accessible from the outside. To allow for experimentation and debugging, this example creates a bastion node. It's possible to connect via SSH to the bastion node, and then connect to the worker nodes through it (by using the `-J` or `-A` flags). A production setup shouldn't use this bastion node.

To interact with the Kubernetes cluster, use the generated `kubeconfig` file.  To do that, you'll need [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) to connect to it using `kubectl`, passing the generated `kubeconfig_<cluster-name>` file. As in this example:

```
$ kubectl --kubeconfig kubeconfig_flatcar-cluster get nodes
NAME                                       STATUS   ROLES    AGE     VERSION
ip-10-0-2-162.us-east-2.compute.internal   Ready    <none>   4m55s   v1.17.12-eks-7684af
ip-10-0-3-228.us-east-2.compute.internal   Ready    <none>   4m56s   v1.17.12-eks-7684af

$ kubectl --kubeconfig kubeconfig_flatcar-cluster get pods -A
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-mmxtv             1/1     Running   0          5m19s
kube-system   aws-node-z2n9v             1/1     Running   0          5m20s
kube-system   coredns-67bfd975c5-6wfgs   1/1     Running   0          21m
kube-system   coredns-67bfd975c5-ltpc9   1/1     Running   0          21m
kube-system   kube-proxy-dhs5h           1/1     Running   0          5m20s
kube-system   kube-proxy-mm9dp           1/1     Running   0          5m19s
```

Please note that it might take a minute for the cluster to be ready after terraform is done setting it up.

## Destroying the cluster and all associated resources

The cluster as set up will use compute resources that will be billed to your account.  Once you're done using them, you should destroy them, to avoid unnecessary charges.  To do that, you can run:

```
terraform destroy
```
