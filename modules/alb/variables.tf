variable "alb_name" {
  default     = "default"
  description = "The name of the loadbalancer."
}

variable "namespace" {
  description = "The namespace of the environment."
}

variable "environment" {
  description = "The name of the environment."
}

variable "short_region" {
 description = "The short region name."
}

variable "region" {
 description = "The region id (ex: us-east-1, us-west-2)."
}

variable "application" {
description = "The name of the application."
}
variable "stage" {}

variable "public_subnet_ids" {
  type        = "list"
  description = "List of public subnet ids to place the loadbalancer in"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "health_check_path" {
  default     = "/"
  description = "The default health check path"
}

variable "allow_cidr_block" {
  default     = "0.0.0.0/0"
  description = "Specify cird block that is allowd to acces the LoadBalancer"
}
