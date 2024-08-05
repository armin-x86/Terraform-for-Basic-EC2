# challenge/terraform
# output.tf

output "vpc_id" {
  description = "ID of the vpc"
  value       = aws_vpc.keyrock_lab_vpc.id
}

output "loadbalancer_dns" {
  description = "DNS Address of the Application Loadbalancer"
  value       = aws_lb.web_server_lb.dns_name
}
