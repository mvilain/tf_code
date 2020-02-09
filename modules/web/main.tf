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

// ================================================== ELB
resource "aws_elb" "web" {
  name               = "${var.env_name}-web-lb"
  security_groups    = [ var.sg_ids ]
  subnets            = [ var.subnets.0, var.subnets.1, var.subnets.2 ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  tags = {
    "Terraform" : "true"
    "Name"      : "${var.env_name}-web-lb"
  }
}

// ================================================== AUTOSCALING
resource "aws_autoscaling_group" "web" {
  name                 = "${var.env_name}-web-asg"
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
    value               = "${var.env_name}-web"
    propagate_at_launch = true
  }
}

// ================================================== ELB -> ASG
resource "aws_autoscaling_attachment" "asg_att" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  elb                    = aws_elb.web.id
}

resource "aws_launch_configuration" "web" {
  name              = "${var.env_name}-web-lc"
  image_id          = var.ami
  instance_type     = var.type
  security_groups = [ var.sg_ids ]

  root_block_device {
    delete_on_termination = true
  }
}
