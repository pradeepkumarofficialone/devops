# Component	Details
# Application Load Balancer (ALB): Creates an external ALB with public subnets and security groups.
# Target Group: Configures a target group to route traffic to EC2 instances over HTTP (port 80).
# Health Checks: Implements health checks for instances with custom intervals, timeouts, and thresholds.
# Listener: Adds an HTTP listener on port 80 to forward traffic to the target group.
# Lifecycle Rule: Ensures target group resources are recreated safely during updates.

# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.pub_sub_1a_id,var.pub_sub_2b_id]
  enable_deletion_protection = false

  tags   = {
    Name = "${var.project_name}"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    timeout             = 5
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
