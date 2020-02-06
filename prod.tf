//================================================== VARIABLES
variable "prod_web_region" {
  type    = string
}

variable "prod_web_subnets" {
  type    = list(string)
}

variable "prod_web_whitelist" {
  type    = list(string)
}

variable "prod_web_desired_capacity" {
  type    = number
}

variable "prod_web_max_size" {
  type    = number
}

variable "prod_web_min_size" {
  type    = number
}

#data "aws_ami" "ubuntu" {
#  most_recent  = true
#  filter {
#    name = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#  }
#  filter {
#    name = "virtualization-type"
#    values = ["hvm"]
#  }
#  owners = ["099720109477"] # Canonical
#}

# Bitnami nginx Open Source Cert in us-east-2
variable "prod_web_ami" {
  type        = string
  description = "region (AMI) to use for nginx"
#  validation {
#    condition     = length(var.prod_web_ami) > 4 && substr(var.prod_web_ami, 0, 4) == "ami-"
#    error_message = "Machine Image must be a valid AMI id, starting with \"ami-\"."
#  }
}

variable "prod_web_type" {
  type        = string
  description = "region (AMI) to use for nginx"
}

######################################################################

provider "aws" {
  profile = "default"
  region  = var.prod_web_region
}

//================================================== S3
resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "mvilain-prod-tf-course-20200203"
  acl    = "private"
}

// ================================================== NETWORK + SUBNETS
module "net_setup" {
  source = "./modules/net"

  net_name  = "prod"
  region    = var.prod_web_region
  subnets   = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
  whitelist = [ "0.0.0.0/0" ]
 
 #outputs:
 # list(string, three elements) 
 #      module.net_setup.net_subnets_ids = []
 # string
 #      module.net_setup.net_sg_id
}

//================================================== INSTANCES
# don't bother launching this as autoscale will do it automatically
#resource "aws_instance" "prod_web" {
#  count         = 2
#  ami           = var.prod_web_ami
#  instance_type = var.prod_web_type
#
#  vpc_security_group_ids = [
#    aws_security_group.prod_web.id
#  ]
#
#  tags = {
#    "Terraform" : "true"
#    "Name"      : "prod_web"
#  }
#}
#
//================================================== EIP -> EC2
#resource "aws_eip_association" "prod_web" {
#  instance_id      = aws_instance.prod_web.0.id
#  allocation_id    = aws_eip.prod_web.id
#}
#
#resource "aws_eip" "prod_web" {
#}

//================================================== ELB
resource "aws_elb" "prod_web"{
  name            = "prod-web-lb"

  security_groups = [ 
    module.net_setup.net_sg_id 
    ]

  subnets         = [ 
    module.net_setup.net_subnets_ids.0,
    module.net_setup.net_subnets_ids.1,
    module.net_setup.net_subnets_ids.2
    ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  tags = {
    "Terraform" : "true"
    "Name"      : "prod_web"
  }
}

//================================================== AUTOSCALING
resource "aws_autoscaling_group" "prod_web" {
  name                 = "prod_web_asg"
  desired_capacity     = var.prod_web_desired_capacity
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.prod_web.id
  max_size             = var.prod_web_max_size
  min_size             = var.prod_web_min_size
  availability_zones   = var.prod_web_subnets.*
#  load_balancers       = [ aws_elb.prod_web.id ]

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "prod_web"
    propagate_at_launch = true
  }
}

# connect ELB and autoscale group
resource "aws_autoscaling_attachment" "prod_asg_att" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb                    = aws_elb.prod_web.id
}

resource "aws_launch_configuration" "prod_web" {
  name              = "prod_web_lc"
  image_id          = var.prod_web_ami
  instance_type     = var.prod_web_type

  security_groups = [ 
    module.net_setup.net_sg_id 
    ]

  root_block_device {
    delete_on_termination = true
  }
}
