# challenge/terraform
# terraform.tfvars


# If the subnet is going to be public (routed to igw), prefix the object
# name with public otherwise `map_public_ip_on_launch` wouldn't be set
# to `true`.
subnets = {
  public_1_webservices = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Project    = "keyrock-assignment"
      Tier       = "web"
      Type       = "public"
      Owner      = "devops-team"
      CostCenter = "IT-department"
    }
  },
  public_2_webservices = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Project    = "keyrock-assignment"
      Tier       = "web"
      Type       = "public"
      Owner      = "devops-team"
      CostCenter = "IT-department"
    }
  }
}

ingress_rules = {
  http_ingress_http = {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_block      = ["0.0.0.0/0"]
    ipv6_cidr_block = ["::/0"]
  },
  http_ingress_https = {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_block      = ["0.0.0.0/0"]
    ipv6_cidr_block = ["::/0"]
  }
}

egress_rules = {
  http_egress_tcp_all = {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_block      = ["0.0.0.0/0"]
    ipv6_cidr_block = ["::/0"]
  },
  http_egress_udp_all = {
    from_port       = 0
    to_port         = 65535
    protocol        = "udp"
    cidr_block      = ["0.0.0.0/0"]
    ipv6_cidr_block = ["::/0"]
  }
}
