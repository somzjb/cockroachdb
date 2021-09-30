resource "aws_lb_target_group" "cockroach_target_group" {
  name        = "cockroach-target-group"
  port        = 26257
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true
    path = "/health?ready=1"
    port = 8080
    protocol = "HTTP"
 }
	
}

resource "aws_lb_target_group_attachment" "register_nodes" {
  count            = length(var.ec2_id)
  target_group_arn = aws_lb_target_group.cockroach_target_group.arn
  target_id        = var.ec2_id[count.index]
  port             = 26257
}


variable "vpc_id" {}
variable "ec2_id" {}
output "target_group" {
  value = aws_lb_target_group.cockroach_target_group.arn
}
