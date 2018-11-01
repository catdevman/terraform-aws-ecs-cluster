module "alb_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "${var.environment}"
  name       = ""
  delimiter  = "-"
  tags = "${var.tags}"
}

module "alb" {
  source = "modules/alb"

  environment  = "${var.environment}"
  namespace    = "${var.namespace}"
  region       = "${var.region}"
  short_region = "${var.short_region}"
  application  = "${var.application}"
  stage        = "${var.stage}"

  alb_name          = "${var.cluster}"
  vpc_id            = "${var.vpc_id}"
  public_subnet_ids = "${var.public_subnet_ids}"
}

resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "TCP"
  source_security_group_id = "${module.alb.alb_security_group_id}"
  security_group_id        = "${module.ecs_instances.ecs_instance_security_group_id}"
}

# Why we need ECS instance policies http://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
# ECS roles explained here http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_managed_policies.html
# Some other ECS policy examples http://docs.aws.amazon.com/AmazonECS/latest/developerguide/IAMPolicyExamples.html

module "ecs_instance_role_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.environment}"
  stage      = "ecs"
  name       = "instancerole"
  delimiter  = "_"
  tags = "${var.tags}"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${module.ecs_instance_role_label.id}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

module "ecs_iam_instance_profile_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.environment}"
  stage      = "ecs"
  name       = "instanceprofile"
  delimiter  = "_"
  tags = "${var.tags}"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${module.ecs_iam_instance_profile_label.id}"
  path = "/"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

module "ecs_lb_iam_role_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.environment}"
  stage      = "ecs"
  name       = "instanceprofile"
  delimiter  = "_"
  tags = "${var.tags}"
}

resource "aws_iam_role" "ecs_lb_role" {
  name = "${module.ecs_lb_iam_role_label.id}"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_lb" {
  role       = "${aws_iam_role.ecs_lb_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

module "ecs_instances" {
  # module.network = terraform-aws-modules/vpc/aws
  source = "modules/instances"

  region                  = "${var.region}"
  environment             = "${var.environment}"
  cluster                 = "${var.cluster}"
  instance_group          = "${var.instance_group}"
  private_subnet_ids      = "${var.private_subnet_ids}"
  aws_ami                 = "${var.ecs_aws_ami}"
  instance_type           = "${var.instance_type}"
  max_size                = "${var.max_size}"
  min_size                = "${var.min_size}"
  desired_capacity        = "${var.desired_capacity}"
  vpc_id                  = "${var.vpc_id}"
  iam_instance_profile_id = "${aws_iam_instance_profile.ecs.id}"
  key_name                = "${var.key_name}"
  load_balancers          = "${var.load_balancers}"
  depends_id              = "${var.depends_id}"
  custom_userdata         = "${var.custom_userdata}"
  cloudwatch_prefix       = "${var.cloudwatch_prefix}"
  depends_id              = "${var.depends_id}"
  ebs_volume_size         = "${var.ebs_volume_size}"
}

module "ecs_cluster_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "${var.environment}"
  name       = "cluster"
  delimiter  = "-"
  tags = "${var.tags}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${module.ecs_cluster_label.id}"
}
