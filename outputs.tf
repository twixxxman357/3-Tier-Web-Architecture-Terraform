output "vpc_id" {
  value = aws_vpc.this.id
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "web_asg_name" {
  value = aws_autoscaling_group.web_asg.name
}

output "app_asg_name" {
  value = aws_autoscaling_group.app_asg.name
}

output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "aurora_reader_endpoint" {
  value = aws_rds_cluster.aurora.reader_endpoint
}
