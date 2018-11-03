variable "region" {
  description = "Region to create resources in."
  type        = "string"
}

variable "environment" {
  description = "The name of the environment"
}

variable "cloudwatch_prefix" {
  default     = ""
  description = "If you want to avoid cloudwatch collision or you don't want to merge all logs to one log group specify a prefix"
}

variable "cluster" {
  description = "The name of the cluster"
}

variable "instance_group" {
  default     = "default"
  description = "The name of the instances that you consider as a group"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "aws_ami" {
  description = "The AWS ami id to use"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type to use"
}

variable "max_size" {
  default     = 1
  description = "Maximum size of the nodes in the cluster"
}

variable "min_size" {
  default     = 1
  description = "Minimum size of the nodes in the cluster"
}

#For more explenation see http://docs.aws.amazon.com/autoscaling/latest/userguide/WhatIsAutoScaling.html
variable "desired_capacity" {
  default     = 1
  description = "The desired capacity of the cluster"
}

variable "iam_instance_profile_id" {
  description = "The id of the instance profile that should be used for the instances"
}

variable "private_subnet_ids" {
  type        = "list"
  description = "The list of private subnets to place the instances in"
}

variable "load_balancers" {
  type        = "list"
  default     = []
  description = "The load balancers to couple to the instances. Only used when NOT using ALB"
}

variable "depends_id" {
  description = "Workaround to wait for the NAT gateway to finish before starting the instances"
}

variable "key_name" {
  description = "SSH key name to be used"
}

variable "custom_userdata" {
  default     = ""
  description = "Inject extra command in the instance template to be run on boot"
}

variable "ecs_config" {
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "timezone" {
  default     = "Universal"
  description = "Timezone file path from the /usr/share/zoneinfo path."
}

variable "ecs_logging" {
  default     = "[\"json-file\",\"awslogs\"]"
  description = "Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well"
}

variable "log_retention_in_days" {
  default     = 30
  description = ""
}

variable "ebs_volume_size" {
  default     = "22"
  description = "Default size is 22GB. This volume is mapped to /dev/xvdcz for Docker."
}

variable "scale_up_cooldown_seconds" {
  default     = "60"
  description = "Default time is 60 seconds."
}

variable "scale_down_cooldown_seconds" {
  default     = "60"
  description = "Default time is 60 seconds."
}

variable "high_cpu_evaluation_periods" {
  default = "2"
}

variable "low_cpu_evaluation_periods" {
  default = "2"
}

variable "high_cpu_period_seconds" {
  default = "60"
}

variable "low_cpu_period_seconds" {
  default = "60"
}

variable "high_cpu_threshold_percent" {
  default = "90"
}

variable "low_cpu_threshold_percent" {
  default = "70"
}

variable "high_memory_evaluation_periods" {
  default = "2"
}

variable "low_memory_evaluation_periods" {
  default = "2"
}

variable "high_memory_period_seconds" {
  default = "60"
}

variable "low_memory_period_seconds" {
  default = "60"
}

variable "high_memory_threshold_percent" {
  default = "90"
}

variable "low_memory_threshold_percent" {
  default = "70"
}
