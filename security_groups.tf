# ALB allows HTTP (80) from anywhere
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow HTTP inbound from internet to ALB"

  ingress {
    description = "HTTP"
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

# Web tier SG: only allow from ALB
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow traffic from ALB"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "From ALB"
  }
  # allow SSH from a limited IP (change as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change for security
    description = "SSH (change CIDR in production)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App tier SG: only allow from Web tier SG
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow web tier to talk to app tier"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "From Web tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB SG: allow only app tier to connect to DB port 3306 (Aurora MySQL)
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow app tier to connect to DB"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "From App tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
