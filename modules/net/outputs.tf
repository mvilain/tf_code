# net outputs.tf

output "net_subnets_ids" {
  value = [ 
  aws_default_subnet.default_az0.id,
  aws_default_subnet.default_az1.id,
  aws_default_subnet.default_az2.id
  ]
}

output "net_sg_id" {
  value = aws_security_group.net_sg.id
}
