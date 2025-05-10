resource "aws_lb" "lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = var.subnets

  enable_deletion_protection = false
  tags = {
    Environment = "sandbox"
    CreatedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "target" {
  name        = var.tg_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}