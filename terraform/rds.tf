data "aws_iam_policy_document" "rds" {
  statement {
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
}

resource "aws_kms_key" "rds" {
  description             = "Key for RDS encryption"
  deletion_window_in_days = 14
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.rds.json
}

resource "aws_kms_alias" "rds" {
  name          = "alias/rds"
  target_key_id = aws_kms_key.rds.key_id
}

data "aws_secretsmanager_secret_version" "pgadmin" {
  secret_id = "dev/rds/pgadmin"
}

data "aws_secretsmanager_secret_version" "jira" {
  secret_id = "dev/rds/jira"
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "jira"
  engine                  = "aurora-postgresql"
  availability_zones      = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
  database_name           = "jirabd"
  master_username         = "pgadmin"
  master_password         = jsondecode(data.aws_secretsmanager_secret_version.pgadmin.secret_string)["pgadmin"]
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  kms_key_id              = aws_kms_key.rds.arn
  storage_encrypted       = true
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "default" {
  cluster_identifier  = aws_rds_cluster.default.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.default.engine
  engine_version      = aws_rds_cluster.default.engine_version
  publicly_accessible = false
}
