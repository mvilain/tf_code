provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "mvilain-prod-tf-course-20200203"
  acl    = "private"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
