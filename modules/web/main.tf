// web_server main.tf

#variable "env_name" {
#  type        = string
#  description = "environment name of the type of network (prod/stage/test/dev)"
#  default     = "prod"
#}
#
#variable "az" {
#  type        = list(string)
#  description = "regional availabity zones"
#}
#
#variable "subnets" {
#  type        = list(string)
#  description = "regional subnet ids"
#}
#
#variable "sg_ids" {
#  description = "security groups for web_server"
#  type        = string
#}
#
## Bitnami nginx Open Source Cert in us-east-2
#variable "ami" {
#  type        = string
#  description = "region (AMI) to use for nginx"
#  default     = "ami-06249d482a680ae8d"
#}
#
#variable "type" {
#  type        = string
#  default     = "t2.nano"
#}
#
#variable "desired_capacity" {
#  type        = number
#  default     = 1
#}
#
#variable "max_size" {
#  type        = number
#  default     = 1
#}
#
#variable "min_size" {
#  type        = number
#  default     = 1
#}

//================================================== ELB
# can't specify env_name here as tf won't allow variables in strings
resource "aws_elb" "web" {
  name               = "web-lb"

  security_groups    = [ 
    var.sg_ids
    ]

  subnets            = [ 
    var.subnets.0,
    var.subnets.1,
    var.subnets.2
    ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  tags = {
    "Terraform" : "true"
    "Name"      : "web-lb"
  }
}

//================================================== AUTOSCALING
# can't specify env_name here as tf won't allow variables in strings
resource "aws_autoscaling_group" "web" {
  name                 = "web-asg"
  desired_capacity     = var.desired_capacity
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.web.id
  max_size             = var.max_size
  min_size             = var.min_size
  availability_zones   = var.az.*
#  load_balancers       = [ aws_elb.prod_web.id ]

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

//================================================== ELB -> ASG
resource "aws_autoscaling_attachment" "asg_att" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  elb                    = aws_elb.web.id
}

# can't specify env_name here as tf won't allow variables in strings
resource "aws_launch_configuration" "web" {
  name              = "web-lc"
  image_id          = var.ami
  instance_type     = var.type

  root_block_device {
    delete_on_termination = true
  }

  security_groups = [ 
    var.sg_ids
    ]

}