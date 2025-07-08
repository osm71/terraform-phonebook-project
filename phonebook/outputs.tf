output "websiteurl" {
    value = "http://${aws_route53_record.app-53record.name}"
  
}

output "dns-name" {
    value = "hhtp://${aws_alb.app-alb.dns_name}"

  
}

output "adress" {

    value = aws_db_instance.app-db.address
  
}

output "endpint" {

    value = aws_db_instance.app-db.endpoint
  
}
