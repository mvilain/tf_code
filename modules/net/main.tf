// net main.tf

#variable "env_name" {
#  type        = string
#  description = "environment name of the type of network (prod/stage/test/dev)"
#  default     = "prod"
#}
#
#variable "region" {
#  type        = string
#  description = "region (AMI) to use for nginx web service"
#  default     = "us-east-2"
#}
#
#variable "subnets" {
#  type        = list(string)
#  default     = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
#}
#
#variable "whitelist" {
#  type        = list(string)
#  default     = [ "0.0.0.0/0" ]
#}

# ================================================== NETWORK + SUBNETS
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az0" {
  availability_zone = var.subnets.0
  
    tags = {
    "Terraform" : "true"
    "Name"      : "${var.env_name}-az0"
  }
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = var.subnets.1
  
    tags = {
    "Terraform" : "true"
    "Name"      : "${var.env_name}-az1"
  }
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = var.subnets.2
  
    tags = {
    "Terraform" : "true"
    "Name"      : "${var.env_name}-az2"
  }
}

# output "net_subnets_ids" {
#   value = [ 
#   aws_default_subnet.default_az0.id,
#   aws_default_subnet.default_az1.id,
#   aws_default_subnet.default_az2.id
#   ]
# }

# ================================================== SECURITY GROUPS
resource "aws_security_group" "net_sg" {
  name  = "${var.env_name}_sg"
  description = "Allow standard http+https ports inbound, all outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist
  }

  tags = {
    "Terraform" : "true"
    "Name"      : "${var.env_name}-sg"
  }
}

# output "net_sg_id" {
#   value = aws_security_group.net_sg.id
# }
