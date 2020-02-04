provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

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

resource "aws_default_subnet" "default_azA" {
  availability_zone = "us-east-2a"
  
    tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_azA"
  }
}
resource "aws_default_subnet" "default_azB" {
  availability_zone = "us-east-2b"
  
    tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_azB"
  }
}
resource "aws_default_subnet" "default_azC" {
  availability_zone = "us-east-2c"
  
    tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_azC"
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
      "1.2.3.4/32"
    ]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
      "1.2.3.4/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
      "1.2.3.4/32"
    ]
  }

  tags = {
    "Terraform" : "true"
    "Name"      : "prod_web_sg"
  }
}

# ================================================== INSTANCES
# Bitnami NGINX Open Source Cert in us-east-2
resource "aws_instance" "prod_web" {
  count         = 2
  ami           = "ami-06249d482a680ae8d"
  instance_type = "t2.nano"


# ================================================== SG -> EC2
  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" : "true"
    "Name"      : "prod_web"
  }

}

# ================================================== EIP -> EC2
resource "aws_eip_association" "prod_web" {
  instance_id      = aws_instance.prod_web.0.id
  allocation_id    = aws_eip.prod_web.id
}

resource "aws_eip" "prod_web" {
}

# ================================================== ELB
resource "aws_elb" "prod_web"{
  name            = "prod-web-lb"
  instances       = aws_instance.prod_web.*.id
  subnets         = [ 
    aws_default_subnet.default_azA.id,
    aws_default_subnet.default_azB.id, 
    aws_default_subnet.default_azC.id
    ]
  security_groups = [aws_security_group.prod_web.id]

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
