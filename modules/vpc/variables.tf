variable "cidr" {
  description = "CDIR block range for this vpc. (ex: 10.0.0.0/16)"
  type        = "string"
}

variable "availability_zones" {
  description = "Availablility zones for this vpc."
  type        = "list"
}

variable "private_subnets" {
  description = "Availablility zones for this vpc."
  type        = "list"
}

variable "public_subnets" {
  description = "Availablility zones for this vpc."
  type        = "list"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks."
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks."
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC."
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC."
  default     = true
}

variable "namespace" {
  description = "Namespace"
  type        = "string"
}

variable "application" {
  description = "Application"
  type        = "string"
}

variable "stage" {
  description = "Stage"
  type        = "string"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  default     = {}
  type        = "map"
}
