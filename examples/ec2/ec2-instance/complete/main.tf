# Configure the AWS provider with the specified region and profile
provider "aws" {
  #region  = var.region  # AWS region (e.g., ca-central-1)
  profile = var.profile  # AWS CLI profile to use
  default_tags {
    tags = var.default_tags
  }

}

# Include a module for the required AWS provider plugin
module "terraform_provider_plugin" {
  source = "../../../../../tools/required_plugins/required_aws(v)"  # Path to the required AWS provider plugin module
}

# Include a module for the required Terraform version
module "terraform_version" {
  source = "../../../../../tools/required_plugins/required_terraform(v)"  # Path to the required Terraform version module
}

# Include a module for the AWS provider configuration
module "aws_provider" {
  source = "../../../../../tools/required_providers/aws"  # Path to the AWS provider configuration module
  region = var.region  # AWS region
}

# Data source to get the available AWS availability zones
data "aws_availability_zones" "available" {}

# Define local variables
locals {
  name = "awlappturbonapp01"  # Name for the resources

  user_data = var.user_data_base64  # Base64 encoded user data

  # Tags to be applied to the resources
  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/manulife-innersource/aws-catalog.git"
  }
}

# Include a module for creating EC2 instances with complete configuration
module "ec2_complete" {
  source = "../../../../../modules/compute/ec2-instances"  # Path to the EC2 instances module

##Security Group Variables declaration
vpc_id                     = var.vpc_id
security_group_name        = var.security_group_name
security_group_description = var.security_group_description
ingress_rules = var.ingress_rules
egress_rules = var.egress_rules

instances = var.instances
provider_name    = var.provider_name
os_name          = var.os_name
server_type = var.server_type
environment_name = var.environment_name
purpose = var.purpose
#additional_tags = var.additional_tags

##Ec2 instance###################################################################################
  #name                     = var.name  # Name for the EC2 instances
  #instance_count           = var.instance_count  # Number of instances to create
  ami                      = var.ami  # AMI ID for the instances
  instance_type            = var.instance_type  # Instance type (e.g., t2.micro)
  availability_zone        = var.availability_zone  # Availability zone for the instances
  subnet_id                = var.subnet_id  # Subnet ID for the instances
  vpc_security_group_ids   = var.vpc_security_group_ids  # Security group IDs for the instances
  # placement_group          = var.placement_group  # Placement group for the instances (commented out)
  create_eip               = var.create_eip  # Whether to create an Elastic IP
  # disable_api_stop         = var.disable_api_stop  # Whether to disable API stop (commented out)
  #create_iam_instance_profile = var.create_iam_instance_profile  # Whether to create an IAM instance profile
  #iam_role_description     = var.iam_role_description  # Description for the IAM role
  #iam_role_policies        = var.iam_role_policies  # Policies to attach to the IAM role
  iam_instance_profile = var.iam_instance_profile

  hibernation              = var.hibernation  # Enable hibernation for the instances
  enclave_options_enabled  = var.enclave_options_enabled  # Enable enclave options

  user_data_base64            = var.user_data_base64  # Base64 encoded user data
  user_data_replace_on_change = var.user_data_replace_on_change  # Replace user data on change

  network_interface = var.network_interface


  #enable_volume_tags = var.enable_volume_tags  # Enable tags for volumes

  # Configuration for the root block device
  root_block_device = [
    {
      encrypted   = var.root_block_device_encrypted  # Encrypt the root block device
      volume_type = var.root_block_device_volume_type  # Volume type (e.g., gp2)
      throughput  = var.root_block_device_throughput  # Throughput for the volume
      volume_size = var.root_block_device_volume_size  # Size of the volume
      tags        = var.root_volume_tags  # Tags for the volume
    },
  ]

  # Configuration for additional EBS block devices
  ebs_block_device = [
    {
      device_name = var.ebs_block_device_device_name  # Device name (e.g., /dev/sdh)
      volume_type = var.ebs_block_device_volume_type  # Volume type (e.g., gp2)
      volume_size = var.ebs_block_device_volume_size  # Size of the volume
      throughput  = var.ebs_block_device_throughput  # Throughput for the volume
      encrypted   = var.ebs_block_device_encrypted  # Encrypt the volume
      kms_key_id  = var.ebs_block_device_kms_key_id  # KMS key ID for encryption
      tags        = var.ebs_volume_tags  # Tags for the volume
    }
  ]

  tags = var.tags  # Tags to be applied to the instances

}
