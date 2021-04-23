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

## REMOTE S3 STATE

https://github.com/willfarrell/terraform-state-module

```
variable "name" {
  default = "NAME"
}
variable "region" {
  default = "us-east-1"
}
variable "profile" {
  default = "farrelllabs"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "state" {
  source = "git@github.com/willfarrell/terraform-state-module"
  name = "${var.name}"
}

# Used in backend.s3 block
output "backend_s3_region" {
  value = "${var.region}"
}
output "backend_s3_profile" {
  value = "${var.profile}"
}
output "backend_s3_dynamodb_table" {
  value = "${module.state.dynamodb_table_id}"
}
output "backend_s3_bucket" {
  value = "${module.state.s3_bucket_id}"
}
output "backend_s3_bucket_logs" {
  value = "${module.state.s3_bucket_logs_id}"
}
```

## Appendix A

### adding submodules to git repository

see https://git-scm.com/book/en/v2/Git-Tools-Submodules

- git submodule add https://github.com/terraform-in-action/manning-code.git
- git submodule add https://github.com/brikis98/terraform-up-and-running-code

### removing submodules from git

Here's how to remove submodules:

- Delete the relevant section from the .gitmodules file.
- Stage the .gitmodules changes git add .gitmodules
- Delete the relevant section from .git/config.
- Run git rm --cached path_to_submodule (no trailing slash).
- Run rm -rf .git/modules/path_to_submodule (no trailing slash).
- Commit git commit -m "Removed submodule "
- Delete the now untracked submodule files rm -rf path_to_submodule

from [https://gist.github.com/myusuf3/7f645819ded92bda6677](How to delete a submodule)
