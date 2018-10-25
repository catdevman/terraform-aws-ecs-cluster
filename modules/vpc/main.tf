module "network_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "vpc"
  delimiter  = "-"
  tags = "${var.tags}"
}

module "network" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${module.network_label.id}"
  cidr = "${var.cidr}"

  azs             = ["${var.availability_zones}"]
  private_subnets = ["${var.private_subnets}"]
  public_subnets  = ["${var.public_subnets}"]

  enable_nat_gateway = "${var.enable_nat_gateway}"
  single_nat_gateway = "${var.single_nat_gateway}"

  enable_dns_support   = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags = "${module.network_label.tags}"
}
