data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.target_vpc.id
  tags = {
    tier = "db"
  }
}

data "aws_vpc" "target_vpc" {
  tags = {
    Name = "${var.target_vpc}"
  }
}

data "aws_security_group" "sg" {
  name = "${var.security_group}"
  vpc_id = data.aws_vpc.target_vpc.id
}

resource "aws_lb" "cockroach_lb" {
  name               = "cockroach-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.private.ids
  enable_deletion_protection = true
  tags = {
    env = "db"
  }
}

resource "aws_lb_listener" "db_listener" {
  load_balancer_arn = aws_lb.cockroach_lb.arn
  port              = "26257"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group
  }
}


variable "security_group" {
}

variable "target_vpc" {}
variable "target_group" {}

output "elb_dns_name" {
 value = aws_lb.cockroach_lb.dns_name
}


