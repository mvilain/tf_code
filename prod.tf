# ================================================== VARIABLES
variable "region" {
  type    = string
  default = "us-east-2"
}

variable "az_subnets" {
  type    = list(string)
  default = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c",
  ]
}

# Bitnami nginx Open Source Cert in us-east-2
variable "nginx_ami" {
  type        = string
  description = "region (AMI) to use for nginx"
  default     = "ami-06249d482a680ae8d"
  
#  validation {
#    condition     = length(var.nginx_ami) > 4 && substr(var.nginx_ami, 0, 4) == "ami-"
#    error_message = "Machine Image must be a valid AMI id, starting with \"ami-\"."
#  }
}

######################################################################

provider "aws" {
  profile = "default"
  region  = var.region
}

# ================================================== S3
resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "mvilain-prod-tf-course-20200203"
  acl    = "private"
}

# ================================================== NETWORK + SUBNETS
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az0" {
  availability_zone = var.az_subnets.0
  
    tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_az0"
  }
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = var.az_subnets.1
  
    tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_az1"
  }
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = var.az_subnets.2
  
    tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_az2"
  }
}

# ================================================== SECURITY GROUPS
resource "aws_security_group" "prod_web" {
  name  = "prod_web"
  description = "Allow standard http+https ports inbound, all outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
#      "1.2.3.4/32"
    ]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
#      "1.2.3.4/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
#      "1.2.3.4/32"
    ]
  }

  tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_sg"
  }
}

# ================================================== INSTANCES
# don't bother launching this as autoscale will do it automatically
#resource "aws_instance" "prod_web" {
#  count         = 2
#  ami           = var.nginx_ami
#  instance_type = "t2.nano"
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

# ================================================== EIP -> EC2
#resource "aws_eip_association" "prod_web" {
#  instance_id      = aws_instance.prod_web.0.id
#  allocation_id    = aws_eip.prod_web.id
#}

#resource "aws_eip" "prod_web" {
#}

# ================================================== ELB
resource "aws_elb" "prod_web"{
  name            = "prod-web-lb"
#  instances       = aws_instance.prod_web.*.id
  security_groups = [aws_security_group.prod_web.id]

  subnets         = [ 
    aws_default_subnet.default_az0.id,
    aws_default_subnet.default_az1.id,
    aws_default_subnet.default_az2.id
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

# ================================================== AUTOSCALING
resource "aws_autoscaling_group" "prod_web" {
  name                 = "prod_web_asg"
  desired_capacity     = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.prod_web.id
  max_size             = 3
  min_size             = 2
  availability_zones   = var.az_subnets.*
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
  image_id          = var.nginx_ami
  instance_type     = "t2.nano"

  security_groups   = [
    aws_security_group.prod_web.id
  ]
  root_block_device {
    delete_on_termination = true
  }
}
