# DB subnet group using private subnets
resource "aws_db_subnet_group" "aurora_subnets" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.private : s.id]
  tags = { Name = "${var.project_name}-aurora-subnets" }
}

# Aurora cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.db_cluster_identifier
  engine                  = var.db_engine
  engine_version          = "5.7.mysql_aurora.2.10.0" # check engine versions for your region
  master_username         = var.db_master_username
  master_password         = var.db_master_password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnets.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  backup_retention_period = 7
  tags = { Name = "${var.project_name}-aurora-cluster" }
}

# Primary instance
resource "aws_rds_cluster_instance" "primary" {
  identifier         = "${var.project_name}-aurora-primary"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnets.name
}

# Read replica instance (Aurora will replicate across AZs)
resource "aws_rds_cluster_instance" "replica" {
  identifier         = "${var.project_name}-aurora-replica"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnets.name
}
