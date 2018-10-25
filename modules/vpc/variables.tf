variable "cidr" {
  description = "Cidr block range for this vpc (ex: 10.0.0.0/16)"
  type = "string"
}

variable "availability_zones" {
  description = "Availablility zones for this vpc"
  type = "list"
}

variable "private_subnets" {
  description = "Availablility zones for this vpc"
  type = "list"
}

variable "public_subnets" {
  description = "Availablility zones for this vpc"
  type = "list"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type = "boolean"
}
variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type = "boolean"
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type = "boolean"
}
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type = "boolean"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {}
  type = "map"
}
