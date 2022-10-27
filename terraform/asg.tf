data "aws_ami" "jira" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jira-node"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

data "aws_security_group" "app" {
  id = "sg-049547c8841a465cb"
}

resource "aws_launch_template" "jira" {
  name                                 = "jira"
  ebs_optimized                        = true
  image_id                             = data.aws_ami.jira.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.large"
  key_name                             = "pascal"
  update_default_version               = true

  user_data = base64encode(templatefile("${path.module}/cloudinit.yml", {
    efs_id              = aws_efs_file_system.default.id,
    jdbc_user           = "jira",
    jdbc_passwd         = jsondecode(data.aws_secretsmanager_secret_version.jira.secret_string)["jira"]
    db_master_passwd    = jsondecode(data.aws_secretsmanager_secret_version.pgadmin.secret_string)["pgadmin"],
    db_master_user      = "pgadmin",
    db_name             = "jirabd",
    db_host             = aws_rds_cluster.default.endpoint,
    db_port             = aws_rds_cluster.default.port,
    atl_product_version = "9.2.0"
    }
  ))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 30
    }
  }

  iam_instance_profile {
    name = "JiraInstanceProfile"
  }

  instance_market_options {
    market_type = "spot"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.app.id]
  }

  placement {
    availability_zone = "ca-central-1"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }
}

resource "aws_autoscaling_group" "jira" {
  availability_zones = ["ca-central-1a", "ca-central-1b"]
  desired_capacity   = 0
  max_size           = 1
  min_size           = 0

  launch_template {
    id      = aws_launch_template.jira.id
    version = "$Latest"
  }
}
