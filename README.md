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