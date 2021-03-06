application = "ecs"
availability_zones = ["us-west-2a", "us-west-2b"]
cidr = "10.20.0.0/16"
desired_capacity = "5"
ecs_aws_ami = "ami-00430184c7bb49914"
instance_type = "t3.medium"
key_name = "fs-usw2-ecs"
max_size = "10"
min_size = "2"
namespace = "fs"
private_subnet_cidrs = ["10.20.110.0/24", "10.20.120.0/24"]
public_subnet_cidrs = ["10.20.10.0/24", "10.20.20.0/24"]
region = "us-west-2"
short_region = "usw2"
