# tf_code
for https://www.linkedin.com/learning/learning-terraform
and https://github.com/brikis98/terraform-up-and-running-code (in brikis98-code)

```
- file naming convention: **component-environment-region-other**

- resource "provider-name" "tf-name" {
  meta-parameters1 = option
  meta-param2      = another-option

# align "=" _locally_ in blocks and meta parameters
  block-parameter {
    arg1       = block-option-1
    argument4  = "block-option-2"
  }
}

```
- use plan to display what's going on and filter out what's not relevent

    terraform graph | egrep -v "meta|close|s3|vpc"
    

## variables

## modules

- modules can exist locally or remotely (e.g. in S3)
  check registry.terraform.io for list of registered user modules
- have a directory structure

  - main.tf -- main source of code or stub to call other parts
  - variables.tf -- input variables with defaults required by the module
  - outputs.tf  -- output variables of what values a module returns
  - README.md  -- description of what the module does, inputs, and expected outputs
  
## DATA SOURCES

```
data "aws_ami" "ubuntu" {
  most_recent  = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
```