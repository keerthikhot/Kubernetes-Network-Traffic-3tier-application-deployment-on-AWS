variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "allowed_http_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to access ALB over HTTP"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
}

variable "nodeport_port" {
  type        = number
  description = "Kubernetes NodePort used by ingress controller"
}


