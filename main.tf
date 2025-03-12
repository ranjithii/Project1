provider "aws" {
  region = "us-east-1"
}

# 1. VPC Setup
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# 2. Security Group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow inbound traffic to EC2 instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets            = [aws_subnet.subnet.id]
}

# 4. Auto Scaling Group (ASG) with Launch Template
resource "aws_launch_template" "asg_template" {
  name          = "asg-launch-template"
  image_id      = "ami-12345678" # Specify your AMI ID here
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ec2_sg.id]
  key_name      = "my-key-pair"
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.subnet.id]
  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }
  load_balancers = [aws_lb.app_lb.id]
}

# 5. S3 Bucket for Static Content
resource "aws_s3_bucket" "static_content" {
  bucket = "my-static-content-bucket"
  acl    = "public-read"
}

# 6. RDS (PostgreSQL)
resource "aws_db_instance" "postgres_db" {
  allocated_storage = 20
  db_instance_class = "db.t2.micro"
  engine            = "postgres"
  engine_version    = "13.3"
  username          = "admin"
  password          = "password"
  db_name           = "mydb"
  multi_az          = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.subnet_group.name
}

# 7. VPC Subnet Setup
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# 8. Route 53 DNS Record
resource "aws_route53_record" "record" {
  zone_id = "your-route53-zone-id"
  name    = "app.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

# 9. CloudWatch for Monitoring
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:my-sns-topic"]
  dimensions = {
    InstanceId = aws_instance.my_instance.id
  }
}

# 10. IAM Role for Jenkins
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect   = "Allow",
      Sid      = ""
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_policy" {
  name = "jenkins-policy"
  role = aws_iam_role.jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = [
        "ec2:DescribeInstances",
        "s3:PutObject",
        "s3:GetObject",
        "cloudwatch:PutMetricData"
      ],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}
