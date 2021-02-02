# The bastion is used for debugging purposes.
# It's accessible from the outside. Users can SSH into it and SSH into the
# cluster from it.
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.flatcar_pro_latest.image_id
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

resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group_rule" "allow_from_bastion" {
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_group_mgmt.id
  to_port                  = 22
  type                     = "ingress"
  source_security_group_id = aws_security_group.bastion.id
}

