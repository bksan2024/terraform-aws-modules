
data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  

  user_data = var.user_data_base64

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ec2-instance"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

module "ec2_complete" {
  source = "../../../../modules/ec2/ec2-instances"

  name                     = var.name
  ami                      = data.aws_ami.amazon_linux.id
  instance_type            = var.instance_type
  availability_zone        = var.availability_zone
  subnet_id                = var.subnet_id
  vpc_security_group_ids   = var.vpc_security_group_ids
  placement_group          = var.placement_group
  create_eip               = var.create_eip
  #disable_api_stop         = var.disable_api_stop
  create_iam_instance_profile = var.create_iam_instance_profile
  iam_role_description     = var.iam_role_description
  iam_role_policies        = var.iam_role_policies

  hibernation              = var.hibernation
  enclave_options_enabled  = var.enclave_options_enabled

  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  cpu_options = {
    core_count       = var.cpu_core_count
    threads_per_core = var.cpu_threads_per_core
  }

  enable_volume_tags = var.enable_volume_tags

  root_block_device = [
    {
      encrypted   = var.root_block_device_encrypted
      volume_type = var.root_block_device_volume_type
      throughput  = var.root_block_device_throughput
      volume_size = var.root_block_device_volume_size
      tags        = var.root_block_device_tags
    },
  ]

  ebs_block_device = [
    {
      device_name = var.ebs_block_device_device_name
      volume_type = var.ebs_block_device_volume_type
      volume_size = var.ebs_block_device_volume_size
      throughput  = var.ebs_block_device_throughput
      encrypted   = var.ebs_block_device_encrypted
      kms_key_id  = var.ebs_block_device_kms_key_id
      tags        = var.ebs_block_device_tags
    }
  ]

  tags = var.tags
}
