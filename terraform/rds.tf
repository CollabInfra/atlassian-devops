resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "jira"
  engine                  = "aurora-postgresql"
  availability_zones      = ["ca-central-1a", "ca-central-1b"]
  database_name           = "jirabd"
  master_username         = "foo"
  master_password         = "bar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "example" {
  cluster_identifier = aws_rds_cluster.example.id
  instance_class     = "db.t2.medium"
  engine             = aws_rds_cluster.example.engine
  engine_version     = aws_rds_cluster.example.engine_version
}
