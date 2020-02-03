provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "tf_course" {
  bucket = "mvilain-tf-course-20200203"
  acl    = "private"
}