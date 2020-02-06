// net variables.tf

variable "env_name" {
  type        = string
  description = "environment name of the type of network (prod/stage/test/dev)"
  default     = "prod"
}

variable "region" {
  type        = string
  description = "region (AMI) to use for nginx web service"
  default     = "us-east-2"
}

variable "subnets" {
  type        = list(string)
  default     = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
}

variable "whitelist" {
  type        = list(string)
  default     = [ "0.0.0.0/0" ]
}
