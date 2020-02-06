//================================================== VARIABLES
variable "prod_web_region" {
  type    = string
}

variable "prod_web_az" {
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

# Bitnami nginx Open Source Cert in us-east-2
variable "prod_web_ami" {
  type        = string
  description = "region (AMI) to use for nginx"
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

  #inputs:
  env_name  = "prod"
  region    = var.prod_web_region
  subnets   = var.prod_web_az
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

// ================================================== PROD WEB
module "web_server" {
  source = "./modules/web"

  #inputs:
  env_name         = "prod"
  az               = var.prod_web_az
  subnets          = [ 
    module.net_setup.net_subnets_ids.0,
    module.net_setup.net_subnets_ids.1,
    module.net_setup.net_subnets_ids.2
  ]
  sg_ids           = module.net_setup.net_sg_id
  ami              = var.prod_web_ami
  type             = var.prod_web_type
  desired_capacity = var.prod_web_desired_capacity
  max_size         = var.prod_web_max_size
  min_size         = var.prod_web_min_size

  #outputs:
  # none 
}
