resource "aws_launch_configuration" "app_launch_config" {
  name          = "app-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0" # example AMI
  instance_type = "t2.micro"

  security_groups = [aws_security_group.allow_all.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  launch_configuration = aws_launch_configuration.app_launch_config.id
  vpc_zone_identifier  = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout  = "0"
}

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.allow_all.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "Hello, World!"
    }
  }
}
