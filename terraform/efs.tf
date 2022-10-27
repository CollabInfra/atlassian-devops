data "aws_iam_policy_document" "efs" {
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
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["elasticfilesystem.${data.aws_region.current.name}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "efs" {
  description             = "Key for EFS encryption"
  deletion_window_in_days = 14
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.efs.json
}

resource "aws_kms_alias" "efs" {
  name          = "alias/efs"
  target_key_id = aws_kms_key.efs.key_id
}

resource "aws_efs_file_system" "default" {
  creation_token = "jira"
  kms_key_id     = aws_kms_key.efs.arn
  encrypted      = true
}

resource "aws_efs_mount_target" "default" {
  file_system_id = aws_efs_file_system.default.id
  subnet_id      = data.aws_subnet.default.id
}

data "aws_subnet" "default" {
  id = "subnet-a6161bdd"
}
