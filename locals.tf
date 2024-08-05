# challenge/terraform
# locals.tf

locals {
  # we will process subnet variable and if prefixed with public
  # we will set `map_public_ip_on_launch` as true.
  processed_subnets = {
    for name, subnet in var.subnets : name => merge(subnet, {
      map_public_ip_on_launch = startswith(name, "public")
      tags                    = merge(subnet.tags, { Name = name })
    })
  }

  # Separate ingress rules for IPv4 and IPv6
  processed_ingress_rules = flatten([
    for rule_name, rule in var.ingress_rules :
    concat(
      [
        for cidr_block in rule.cidr_block : {
          rule_name  = rule_name
          from_port  = rule.from_port
          to_port    = rule.to_port
          protocol   = rule.protocol
          cidr_block = cidr_block
          type       = "ipv4"
        }
      ],
      [
        for ipv6_cidr_block in rule.ipv6_cidr_block : {
          rule_name       = rule_name
          from_port       = rule.from_port
          to_port         = rule.to_port
          protocol        = rule.protocol
          ipv6_cidr_block = ipv6_cidr_block
          type            = "ipv6"
        }
      ]
    )
  ])

  # Separate egress rules for IPv4 and IPv6
  processed_egress_rules = flatten([
    for rule_name, rule in var.egress_rules :
    concat(
      [
        for cidr_block in rule.cidr_block : {
          rule_name  = rule_name
          from_port  = rule.from_port
          to_port    = rule.to_port
          protocol   = rule.protocol
          cidr_block = cidr_block
          type       = "ipv4"
        }
      ],
      [
        for ipv6_cidr_block in rule.ipv6_cidr_block : {
          rule_name       = rule_name
          from_port       = rule.from_port
          to_port         = rule.to_port
          protocol        = rule.protocol
          ipv6_cidr_block = ipv6_cidr_block
          type            = "ipv6"
        }
      ]
    )
  ])
}