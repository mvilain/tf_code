// web_server main.tf

#variable "env_name"
#variable "az"
#variable "subnets"
#variable "sg_ids"
#variable "ami"
#variable "type"
#variable "desired_capacity"
#variable "max_size"
#variable "min_size"

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