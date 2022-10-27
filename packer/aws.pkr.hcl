packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon_linux" {
  ami_name      = "jira-node-ami"
  instance_type = "t2.large"
  region        = "ca-central-1"
  source_ami    = "ami-046a5648dee483245"
  ssh_username  = "ec2-user"
}

build {
  name = "jira"
  sources = [
    "source.amazon-ebs.amazon_linux"
  ]
  provisioner "shell" {
    inline = [
      "sudo yum -y update",
      "sudo amazon-linux-extras install ansible2",
      "ansible-galaxy collection install amazon.aws",
      "ansible-galaxy install datadog.datadog"
    ]
  }
  provisioner "ansible-local" {
    playbook_file   = "../ansible/jira-ci.yml"
    role_paths      = ["../ansible/roles/database_init", "../ansible/roles/product_startup", "../ansible/roles/jira_config", "../ansible/roles/linux_common", "../ansible/roles/aws_common", "../ansible/roles/aws_shared_fs_config", "../ansible/roles/product_common", "../ansible/roles/product_install"]
    extra_arguments = ["--extra-vars", "\"atl_product_edition=${var.atl_product_edition} atl_install_jsd_as_obr=${var.atl_install_jsd_as_obr} datadog_api_key=${var.datadog_api_key} postgresql_major_version=${var.postgresql_major_version} atl_product_version=${var.atl_product_version}\""]
  }
}