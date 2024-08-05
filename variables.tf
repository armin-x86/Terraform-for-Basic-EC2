# challenge/terraform
# variables.tf

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# If the subnet is going to be public (routed to igw), prefix the object
# name with public otherwise `map_public_ip_on_launch` wouldn't be set
# to `true`.
variable "subnets" {
  description = "Map of subnets"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tags              = map(string)
  }))
}

variable "web_server_instance_type" {
  type    = string
  default = "t2.micro"
}

# Consider define prefix for the objects of the same security group
# like prefixing with http_ for all rules for security group named example
variable "ingress_rules" {
  description = "Map of ingress rules with prefixes"
  type = map(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_block      = list(string)
    ipv6_cidr_block = list(string)
  }))
}

# Consider define prefix for the objects of the same security group
# like prefixing with http_ for all rules for security group named example
variable "egress_rules" {
  description = "Map of egress rules with prefixes"
  type = map(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_block      = list(string)
    ipv6_cidr_block = list(string)
  }))
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 4
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Environment = "prod_shared"
  }
}

variable "web_project_default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project    = "keyrock_assignment"
    CostCenter = "IT_department"
    Owner      = "devops_team"
  }
}