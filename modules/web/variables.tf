# web input variables.tf

variable "prod_web_region" {
  type    = string
  description = "region (AMI) to use for nginx web service"
  default = "us-east-2"
}

variable "prod_web_subnets" {
  type    = list(string)
  default = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
}

#data "aws_ami" "ubuntu" {
#  most_recent  = true
#  filter {
#    name = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#  }
#  filter {
#    name = "virtualization-type"
#    values = ["hvm"]
#  }
#  owners = ["099720109477"] # Canonical
#}

# Bitnami nginx Open Source Cert in us-east-2
variable "prod_web_ami" {
  type        = string
  description = "region (AMI) to use for nginx"
  default     = "ami-06249d482a680ae8d"
  
#  validation {
#    condition     = length(var.prod_web_ami) > 4 && substr(var.prod_web_ami, 0, 4) == "ami-"
#    error_message = "Machine Image must be a valid AMI id, starting with \"ami-\"."
#  }
}

variable "prod_web_type" {
  type        = string
  default     = "t2.nano"
}

variable "prod_web_desired_capacity" {
  type    = number
  default = 1
}

variable "prod_web_max_size" {
  type    = number
  default = 1
}

variable "prod_web_min_size" {
  type    = number
  default = 1
}
