variable "environment" {
  description = "Environment name (e.g. prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "allowed_http_ingress_cidrs" {
  description = "CIDRs allowed to access ALB/HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type for ASG"
  type        = string
  default     = "m7i-flex.large"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0b6c6ebed2801a5cb"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "was-default"
}

variable "nodeport_port" {
  description = "Kubernetes NodePort used by ingress controller"
  type        = number
  default     = 30080
}

variable "ssh_ingress_cidrs" {
  description = "CIDRs allowed to SSH to bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

