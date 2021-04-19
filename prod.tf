//================================================== VARIABLES
variable "prod_region" {
  type    = string
}

variable "prod_web_whitelist" {
  type    = list(string)
}

variable "prod_bucket" {
  type    = string
}

variable "prod_dynamodb_table" {
  type    = string
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

//================================================== S3 ENCRYPTED BACKEND+LOCKS
resource "aws_s3_bucket" "tf-backend" {
  bucket = "mvilain-prod-tfstate-backend"
  acl    = "private"

#  lifecycle {
#    prevent_destroy = true
#  }
  
  versioning {
  enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = "mvilain-prod-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name       = "LockID"
    type       = "S"
  }
}

#terraform {
#  backend "local" {
#    path = "./terraform.tfstate"
#  }
#}
#terraform {
#    backend "s3" {
#    bucket         = "mvilain-prod-tfstate-backend"
#    key            = "global/s3/terraform.tfstate"
#    region         = "us-east-2"
#    dynamodb_table = "mvilain-prod-tfstate-locks"
#    encrypt        = true
#  }
#}
#terraform {
#  backend "s3" {
#    bucket         = "mvilain-prod-tfstate-backend"
#    key            = "vpc/terraform.tfstate"
#    region         = "us-east-2"
#    profile        = "tesera"
#    dynamodb_table = "mvilain-prod-tfstate-locks"
#    encrypt        = true
#    kms_key_id     = "arn:aws:kms:us-east-2:<account_id>:key/<key_id>"
#  }
#}
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
