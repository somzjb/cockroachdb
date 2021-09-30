data "aws_security_group" "db_sg" {
 name = var.security_group
}
data "aws_vpc" "target_vpc" {
  tags = {
    Name = "${var.target_vpc}"
  }
}

resource "aws_security_group_rule" "inter_com_rule" {
  type              = "ingress"
  from_port         = 26257
  to_port           = 26257
  protocol          = "tcp"
  security_group_id = data.aws_security_group.db_sg.id
  self = true
}
resource "aws_security_group_rule" "db_console_access_rule" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = data.aws_security_group.db_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "app_access_rule" {
  type              = "ingress"
  from_port         = 26257
  to_port           = 26257
  protocol          = "tcp"
  security_group_id = data.aws_security_group.db_sg.id
  cidr_blocks = var.app_access_rule
}
resource "aws_security_group_rule" "lb_health_check_com" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = data.aws_security_group.db_sg.id
  cidr_blocks = [data.aws_vpc.target_vpc.cidr_block]
}

variable "target_vpc" {}
variable "security_group" {}
variable "app_access_rule" { 
  type = list(string)
}
