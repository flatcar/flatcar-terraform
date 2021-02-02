# Get the latest Flatcar AMI available for the given channel
data "aws_ami" "flatcar_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-${var.flatcar_channel}-*"]
  }
}

# Prepare the ignition config that turns Flatcar instances into EKS nodes
data "template_file" "node_ignition_tmpl" {
  template = file("${path.module}/node-ignition.yaml.tpl")

  vars = {
    aws_region       = var.aws_region
    cluster_name     = var.cluster_name
    cluster_auth     = module.eks.cluster_certificate_authority_data
    cluster_endpoint = module.eks.cluster_endpoint
  }
}

data "ct_config" "node_ignition" {
  content      = data.template_file.node_ignition_tmpl.rendered
  pretty_print = false
}

resource "aws_key_pair" "ssh" {
  key_name   = var.cluster_name
  public_key = var.ssh_public_key
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "dev"
  }

  vpc_id = module.vpc.vpc_id

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  worker_groups = [
    {
      name                          = "worker-group"
      ami_id                        = data.aws_ami.flatcar_latest.image_id
      instance_type                 = var.instance_type
      root_volume_size              = 20
      root_volume_type              = "gp2"
      userdata_template_file        = data.ct_config.node_ignition.rendered
      asg_desired_capacity          = var.worker_group_size
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
      key_name                      = aws_key_pair.ssh.key_name
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# The bastion is used for debugging purposes.
# It can be deleted if not needed.
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.flatcar_latest.image_id
  instance_type = var.bastion_instance_type
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  key_name = aws_key_pair.ssh.key_name

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
  subnet_id = module.vpc.public_subnets[0]
}
