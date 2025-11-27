# IAM role for EC2 profile (optional - for SSM)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Launch template for web tier
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type_web

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from web tier" > /var/www/html/index.html
              # install httpd/nginx as required
              EOF)
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type_app

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from app tier" > /tmp/app.txt
              EOF)
}

# Auto Scaling Groups for web + app
resource "aws_autoscaling_group" "web_asg" {
  name                      = "${var.project_name}-web-asg"
  max_size                  = var.desired_web_count + 1
  min_size                  = var.desired_web_count
  desired_capacity          = var.desired_web_count
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  vpc_zone_identifier = [for s in aws_subnet.public : s.id]
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project_name}-app-asg"
  max_size                  = var.desired_app_count + 1
  min_size                  = var.desired_app_count
  desired_capacity          = var.desired_app_count
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]
  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }
}
