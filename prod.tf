provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "mvilain-prod-tf-course-20200203"
  acl    = "private"
}

#resource "aws_default_vpc" "default" {
#  tags = {
#    Name = "Default VPC"
#  }
#}

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

# Bitnami NGINX Open Source Certified us-east-2 ami-06249d482a680ae8d
resource "aws_instance" "prod_web" {
  ami           = "ami-06249d482a680ae8d"
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" : "true"
    "Name"      : "prod_web"
  }

}
