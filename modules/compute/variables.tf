variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for ASG"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID for app instances"
}

variable "target_group_arn" {
  type        = string
  description = "Target group ARN for ALB"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for compute resources"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}

variable "nodeport_port" {
  type        = number
  description = "NodePort exposed by kind cluster"
}
