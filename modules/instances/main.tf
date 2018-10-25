# You can have multiple ECS clusters in the same account with different resources.
# Therefore all resources created here have the name containing the name of the:
# environment, cluster name in the instance_group name.
# That is also the reason why ecs_instances is a seperate module and not everything is created here.

resource "aws_security_group" "instance" {
  name        = "${var.environment}_${var.cluster}_${var.instance_group}"
  description = "Used in ${var.environment}"
  vpc_id      = "${var.vpc_id}"

  tags {
    Environment   = "${var.environment}"
    Cluster       = "${var.cluster}"
    InstanceGroup = "${var.instance_group}"
  }
}

# We separate the rules from the aws_security_group because then we can manipulate the
# aws_security_group outside of this module
resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.instance.id}"
}

# Default disk size for Docker is 22 gig, see http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
resource "aws_launch_configuration" "launch" {
  name_prefix          = "${var.environment}_${var.cluster}_${var.instance_group}_"
  image_id             = "${var.aws_ami}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.instance.id}"]
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${var.iam_instance_profile_id}"
  key_name             = "${var.key_name}"

  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}"
  }

  # aws_launch_configuration can not be modified.
  # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created
  # before the old one get's destroyed. That's why we use name_prefix instead of name.
  lifecycle {
    create_before_destroy = true
  }
}

# Instances are scaled across availability zones http://docs.aws.amazon.com/autoscaling/latest/userguide/auto-scaling-benefits.html
resource "aws_autoscaling_group" "asg" {
  name                 = "${var.environment}_${var.cluster}_${var.instance_group}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.launch.id}"
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]
  load_balancers       = ["${var.load_balancers}"]

  tag {
    key                 = "Name"
    value               = "${var.environment}_ecs_${var.cluster}_${var.instance_group}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Cluster"
    value               = "${var.cluster}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "InstanceGroup"
    value               = "${var.instance_group}"
    propagate_at_launch = "true"
  }

  # EC2 instances require internet connectivity to boot. Thus EC2 instances must not start before NAT is available.
  # For info why see description in the network module.
  tag {
    key                 = "DependsId"
    value               = "${var.depends_id}"
    propagate_at_launch = "false"
  }

  lifecycle {
   ignore_changes = ["desired_count"]
  }
}

#
# CloudWatch resources
#
resource "aws_autoscaling_policy" "container_instance_scale_up" {
  name                   = "asgScalingPolicy${title(var.environment)}ClusterScaleUp"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.scale_up_cooldown_seconds}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "container_instance_scale_down" {
  name                   = "asgScalingPolicy${title(var.environment)}ClusterScaleDown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.scale_down_cooldown_seconds}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "container_instance_high_cpu" {
  alarm_name          = "alarm${title(var.environment)}ClusterCPUReservationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_cpu_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.high_cpu_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.high_cpu_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster}"
  }

  alarm_description = "Scale up if CPUReservation is above N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "container_instance_low_cpu" {
  alarm_name          = "alarm${title(var.environment)}ClusterCPUReservationLow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_cpu_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.low_cpu_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.low_cpu_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster}"
  }

  alarm_description = "Scale down if the CPUReservation is below N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_down.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.container_instance_high_cpu"]
}

resource "aws_cloudwatch_metric_alarm" "container_instance_high_memory" {
  alarm_name          = "alarm${title(var.environment)}ClusterMemoryReservationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_memory_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.high_memory_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.high_memory_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster}"
  }

  alarm_description = "Scale up if the MemoryReservation is above N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_up.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.container_instance_low_cpu"]
}

resource "aws_cloudwatch_metric_alarm" "container_instance_low_memory" {
  alarm_name          = "alarm${title(var.environment)}ClusterMemoryReservationLow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_memory_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.low_memory_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.low_memory_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster}"
  }

  alarm_description = "Scale down if the MemoryReservation is below N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_down.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.container_instance_high_memory"]
}


data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    ecs_config        = "${var.ecs_config}"
    ecs_logging       = "${var.ecs_logging}"
    cluster_name      = "${var.cluster}"
    env_name          = "${var.environment}"
    custom_userdata   = "${var.custom_userdata}"
    cloudwatch_prefix = "${var.cloudwatch_prefix}"
  }
}