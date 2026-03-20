terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source = "../../modules/network"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  vpc_name = "${var.environment}-vpc"
}

module "security" {
  source = "../../modules/security"

  vpc_id                    = module.network.vpc_id
  allowed_http_ingress_cidrs = var.allowed_http_ingress_cidrs
  name_prefix               = var.environment
  nodeport_port             = var.nodeport_port
}

module "alb" {
  source = "../../modules/alb"

  vpc_id           = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id        = module.security.alb_sg_id
  name_prefix      = var.environment
  target_port      = var.nodeport_port
}

module "compute" {
  source = "../../modules/compute"

  private_subnet_ids = module.network.private_subnet_ids
  app_sg_id          = module.security.app_sg_id
  target_group_arn   = module.alb.target_group_arn
  instance_type      = var.instance_type
  name_prefix        = var.environment
  ami_id             = var.ami_id
  key_name           = var.key_name
  nodeport_port      = var.nodeport_port
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Bastion host security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "SSH from allowed CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  security_group_id        = module.security.app_sg_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "SSH from bastion host"
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.network.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "${var.environment}-bastion"
  }
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the Application Load Balancer"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP for bastion host (SSH entry point)"
}
