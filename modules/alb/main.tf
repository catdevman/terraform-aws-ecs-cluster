module "eg_prod_bastion_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "prod"
  name       = "bastion"
  attributes = ["public"]
  delimiter  = "-"
}

resource "aws_alb" "alb" {
  name            = "${var.alb_name}"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.namespace}-${var.short_region}-${var.application}-${var.stage}-alb"
  vpc_id = "${var.vpc_id}"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "http_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["${var.allow_cidr_block}"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["${var.allow_cidr_block}"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}
