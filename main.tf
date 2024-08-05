# challenge/terraform
# main.tf
provider "aws" {
  region = var.region
}

resource "aws_vpc" "keyrock_lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = merge(var.default_tags, {
    Name = "vpc_web"
  })
}

resource "aws_subnet" "subnets" {
  for_each                = local.processed_subnets
  vpc_id                  = aws_vpc.keyrock_lab_vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  availability_zone       = each.value.availability_zone
  tags                    = merge(each.value.tags, var.web_project_default_tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.keyrock_lab_vpc.id
  tags   = var.default_tags
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.keyrock_lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.default_tags, {
    Type    = "public"
    VpcName = aws_vpc.keyrock_lab_vpc.id
  })
}

resource "aws_route_table_association" "keyrock_assignment_pub_route" {
  for_each = {
    public_1_webservices = aws_subnet.subnets["public_1_webservices"].id,
    public_2_webservices = aws_subnet.subnets["public_2_webservices"].id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route.id
}

resource "aws_security_group" "webserver_http_https" {
  name        = "web_server_sg"
  description = "Allow HTTP/HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.keyrock_lab_vpc.id
  tags        = merge(var.default_tags, var.web_project_default_tags)
}

resource "aws_vpc_security_group_ingress_rule" "web_server_ingress_ipv4" {
  for_each = {
    for rule in local.processed_ingress_rules : rule.rule_name => rule if rule.type == "ipv4" && startswith(rule.rule_name, "http_")
  }

  security_group_id = aws_security_group.webserver_http_https.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_block
  description       = "Allow ${each.key} traffic"
  tags = merge(var.default_tags, var.web_project_default_tags, {
    Direction = "ingress"
  })
}

resource "aws_vpc_security_group_ingress_rule" "web_server_ingress_ipv6" {
  for_each = {
    for rule in local.processed_ingress_rules : rule.rule_name => rule if rule.type == "ipv6" && startswith(rule.rule_name, "http_")
  }

  security_group_id = aws_security_group.webserver_http_https.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv6         = each.value.ipv6_cidr_block
  description       = "Allow ${each.key} traffic"
  tags = merge(var.default_tags, var.web_project_default_tags, {
    Direction = "ingress"
  })
}

resource "aws_vpc_security_group_egress_rule" "web_server_egress_ipv4" {
  for_each = {
    for rule in local.processed_egress_rules : rule.rule_name => rule if rule.type == "ipv4" && startswith(rule.rule_name, "http_")
  }
  security_group_id = aws_security_group.webserver_http_https.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_block
  description       = "Allow ${each.key} traffic"
  tags = merge(var.default_tags, var.web_project_default_tags, {
    Direction = "egress"
  })
}
resource "aws_vpc_security_group_egress_rule" "web_server_egress_ipv6" {
  for_each = {
    for rule in local.processed_egress_rules : rule.rule_name => rule if rule.type == "ipv6" && startswith(rule.rule_name, "http_")
  }
  security_group_id = aws_security_group.webserver_http_https.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv6         = each.value.ipv6_cidr_block
  description       = "Allow ${each.key} traffic"
  tags = merge(var.default_tags, var.web_project_default_tags, {
    Direction = "egress"
  })
}



resource "aws_key_pair" "devops_armin" {
  key_name   = "devops_armin"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgvNTggJby7xSdUjw9p3qRUAx1IC2OMIjK/KE7PVP0zzpr9KeE1OE/5NXGkKnSeoR8hDkAhQ0haxVpunl2oX/xKaKEBLcgCfk6n+3FQHcmFPelKfxChlym4aO6PboDIXYL5B5SA2U2xNG/QeOerXRXvpY4eQAtMnlky4+OViVuAubyKjP7U5NE7BivihZlf8yp/6mM2VMCbaTJ+oo2tN5ghFCpN1f4IQtduI2CEueJlvaGjxHXzRmD/TPd3nqtsPmFJGLrXTTbT3ipQP2uk6NJ4iE26fjeRuKycCTtBt+bXXHfy2Dk93FIGHLMxJhZ539pcZaGhjYQrnMhOO92HPhUQ== armin@teimouri"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  tags = merge(var.default_tags, var.web_project_default_tags, {
    OS = "amazon_linux"
  })
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "web_server_"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.web_server_instance_type
  key_name      = aws_key_pair.devops_armin.key_name

  monitoring {
    enabled = false
  }

  network_interfaces {
    security_groups = [aws_security_group.webserver_http_https.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>This is a test webserver!</div></body></html>" > /var/www/html/index.html
    curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone >> /var/www/html/index.html
    EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.default_tags, var.web_project_default_tags, {
      Name = "web_server"
      Os   = "amazon_linux"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.default_tags, var.web_project_default_tags, {
      Name = "web_server_root"
    })
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  vpc_zone_identifier = [
    aws_subnet.subnets["public_1_webservices"].id,
    aws_subnet.subnets["public_2_webservices"].id
  ]

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.web_server_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "web_server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "prod"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "web_server_lb" {
  name               = "web-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_http_https.id]
  subnets = [
    aws_subnet.subnets["public_1_webservices"].id,
    aws_subnet.subnets["public_2_webservices"].id
  ]

  tags = merge(var.default_tags, var.web_project_default_tags, {
    Name = "web_server_lb"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_tg.arn
  }
}

resource "aws_lb_target_group" "web_server_tg" {
  name     = "web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.keyrock_lab_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.default_tags, var.web_project_default_tags, {
    Name = "web_server_tg"
  })
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
  lb_target_group_arn    = aws_lb_target_group.web_server_tg.arn
}

/*
module "web_server_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6.0"
  name = "web_server"

  instance_type          = "t2.micro"
  key_name               = "devops_armin"
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.web_server.id]
  subnet_id              = aws_subnet.subnets["public_1_webservices"].id
  user_data              = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>This is a test webserver!</div></body></html>" > /var/www/html/index.html
    EOF

  tags = merge(var.default_tags, var.web_project_default_tags, {
    Os     = "amazon_linux"
  })
}
*/


# bastion machine 
# can i consider launching ec2 machines in private subnet and use ALB to delvier the traffic?
# github actions and gitlabci

# automate it
# test if it is working or not
# use ansible for http part
# test if the terraform code is correct, github actions is around or not? make it
# docker file optimizations 
#  terraform code maybe for a kubernetes cluster. GKE
#  readiness and liveness and their importance
# locals vs vars
# Templates: For files that are read in by using the Terraform templatefile function, use the file extension .tftpl. Templates must be placed in a templates/ directory.
# 

# prepare best practice
# https://github.com/aws-samples/aws-terraform-best-practices?tab=readme-ov-file


# issues:
# Parameterization with Variables: code is not flexiable and reuseable
# Tagging: tags are required for management and cost tracking.
# Enhanced Security: restrictive security group rules 
# Resource Naming Conventions: namings should be more meaningfull
# Environment Management: environment-specific variables (prod,staging,...)
# State Management: code was using local state