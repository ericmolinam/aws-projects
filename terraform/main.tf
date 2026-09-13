resource "aws_vpc" "this" {
  cidr_block = local.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-vpc"
  }
}

# ======================================================
# EC2 Launch Template & Auto Scaling Group configuration
# ======================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${local.env}-ec2-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  user_data     = filebase64("${path.module}/script.sh")

  vpc_security_group_ids = [
    aws_security_group.public.id,
  ]

  update_default_version = true
}

resource "aws_autoscaling_group" "this" {
  name = "${local.env}-asg"

  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = [for subnet in aws_subnet.public : subnet.id]

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.env}-web-server"
    propagate_at_launch = true
  }
}

# ==========================================
# Load Balancer & Target Group Configuration
# ==========================================
resource "aws_lb" "this" {
  name               = "${local.env}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Name = "${local.env}-lb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${local.env}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.env}-tg"
  }
}

resource "aws_autoscaling_attachment" "this" {
  # Attach the target group to the AWS Auto Scaling Group
  lb_target_group_arn    = aws_lb_target_group.this.arn
  autoscaling_group_name = aws_autoscaling_group.this.name
}
