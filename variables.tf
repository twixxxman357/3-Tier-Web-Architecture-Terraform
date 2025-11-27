variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "3tier"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24","10.0.12.0/24"]
}

variable "ami_id" {
  description = "AMI id for EC2 instances (Linux)"
  type        = string
  default     = "" # set to a valid AMI id for your region
}

variable "instance_type_web" {
  type    = string
  default = "t3.micro"
}

variable "instance_type_app" {
  type    = string
  default = "t3.micro"
}

variable "desired_web_count" {
  type    = number
  default = 2
}

variable "desired_app_count" {
  type    = number
  default = 2
}

variable "db_cluster_identifier" {
  type    = string
  default = "aurora-cluster"
}

variable "db_engine" {
  type    = string
  default = "aurora-mysql"
}

variable "db_master_username" {
  type    = string
  default = "admin"
}

variable "db_master_password" {
  type      = string
  sensitive = true
  default   = "" # set via TF var or environment
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}
