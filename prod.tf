//================================================== VARIABLES
variable "prod_region" {
  type    = string
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
  region  = var.prod_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
# data.aws_subnet_ids.default.ids lists region's default subnet ids

data "aws_availability_zones" "available" {
  state = "available"
}
# data.aws_availability_zones.available.names is lists region's availability zones
# data.aws_availability_zones.available.zone_ids is lists region's availability zone ids

//================================================== S3 BACKEND
resource "aws_s3_bucket" "backend" {
  bucket = "mvilain-prod-tf-backend-202002"
  acl    = "private"
}

// ================================================== NETWORK + SUBNETS
module "net_setup" {
  source = "./modules/net"

  #inputs:
  env_name  = "prod"
  region    = var.prod_region
  subnets   = data.aws_subnet_ids.default.ids
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
  az               = data.aws_availability_zones.available.names
  subnets          = data.aws_subnet_ids.default.ids
#  az               = var.prod_web_az
#  subnets          = [ 
#    module.net_setup.net_subnets_ids.0,
#    module.net_setup.net_subnets_ids.1,
#    module.net_setup.net_subnets_ids.2
#  ]
  sg_ids           = module.net_setup.net_sg_id
  ami              = var.prod_web_ami
  type             = var.prod_web_type
  desired_capacity = var.prod_web_desired_capacity
  max_size         = var.prod_web_max_size
  min_size         = var.prod_web_min_size

  #outputs:
  # none 
}
