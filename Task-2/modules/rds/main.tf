// Create subnet group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "db subnet group"
  subnet_ids = var.allow-subnets
}
// Generate Password
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"

  keepers = {
    keeper = var.name
  }
}
// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = var.project_mysql
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}
// Get Password from SSM Parameter Store
data "aws_ssm_parameter" "my_rds_password" {
  name       = var.project_mysql
  depends_on = [aws_ssm_parameter.rds_password]
}
// Build Database RDS
resource "aws_db_instance" "rds-db" {
  identifier             = "rds-db-id"
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  port                   = "3306"
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = var.allow-sg
  db_name                = "mydb"
  username               = "administrator"
  password               = data.aws_ssm_parameter.my_rds_password.value
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  apply_immediately      = true
  #storage_encrypted = falce # default
  #max_allocated_storage =   # absent in documentation
  tags = {
    Name   = "Database MySQL"
    Writer = "Eugene Zuev"
  }
}
