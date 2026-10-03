resource "aws_lb" "docmost" {
  name               = "docmost-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name    = "docmost-alb"
    Project = "docmost"
  }
}

resource "aws_lb_target_group" "docmost" {
  name        = "docmost-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  health_check {
    path    = "/api/health"
    matcher = "200"
  }

  tags = {
    Name    = "docmost-targets"
    Project = "docmost"
  }
}

resource "aws_lb_target_group_attachment" "docmost" {
  target_group_arn = aws_lb_target_group.docmost.arn
  target_id        = aws_instance.docmost.id
  port             = 80
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.docmost.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.docmost.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docmost.arn
  }
}
