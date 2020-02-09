prod_region               = "us-east-2"
#prod_web_az                = [ "us-east-2a", "us-east-2b", "us-east-2c" ]

prod_web_whitelist         = [ "0.0.0.0/0" ]

# Bitnami nginx Open Source Cert in us-east-2
prod_web_ami               = "ami-06249d482a680ae8d"
prod_web_type              = "t2.nano"

prod_web_desired_capacity  = 1
prod_web_max_size          = 1
prod_web_min_size          = 1
