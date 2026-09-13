resource "aws_vpc" "this" {
  cidr_block = local.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-vpc"
  }
}

# resource "aws_instance" "this" {
#   for_each = local.public_subnets

#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = "t3.micro"

#   vpc_security_group_ids = [aws_security_group.public.id]
#   subnet_id              = aws_subnet.public[each.key].id

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y && sudo yum install -y httpd
#               sudo systemctl start httpd
#               sudo systemctl enable httpd
#               EOF

#   tags = {
#     Name = "${local.env}-ec2-${each.key}"
#   }
# }

# output "ec2_ip" {
#   value = { for k, v in aws_instance.this : k => v.public_ip }
# }

resource "aws_launch_template" "this" {
  name_prefix   = "${local.env}-asg-"
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

    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${local.env}-asg"
    propagate_at_launch = true
  }
}