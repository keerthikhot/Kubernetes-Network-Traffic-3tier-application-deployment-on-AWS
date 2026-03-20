variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ALB"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for ALB resources"
}

variable "target_port" {
  type        = number
  description = "Port on targets (e.g. NodePort)"
}


