# tflint-ignore: all

# Configure the AWS provider with the specified region and profile
# tflint-ignore: terraform_required_providers
provider "aws" {
  region  = local.region # AWS region (e.g., ca-central-1)
  profile = var.profile  # AWS CLI profile to use
}

locals {
  region    = "ca-central-1" # Default AWS region
  user_data = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
  EOT
}

# Include a module for the required AWS provider plugin
module "terraform_provider_plugin" {
  source = "../../../../../tools/required_plugins/required_aws(v)" # Path to the required AWS provider plugin module
}

# Include a module for the required Terraform version
module "terraform_version" {
  source = "../../../../../tools/required_plugins/required_terraform(v)" # Path to the required Terraform version module
}

# Include a module for the AWS provider configuration
module "aws_provider" {
  source = "../../../../../tools/required_providers/aws" # Path to the AWS provider configuration module
  region = var.region                                    # AWS region
}

# Data source to get the available AWS availability zones
# data "aws_availability_zones" "available" {}

# Include a module for creating EC2 instances with complete configuration
module "ec2_complete" {
  source = "../../ec2-instances" # Path to the EC2 instances module

  os_family       = var.os_family       # Operating system family
  purpose         = var.purpose         # Purpose of the instances
  additional_tags = var.additional_tags # Additional tags for the instances

  # EC2 instance configuration
  instances                   = var.instances                   # List of instances
  availability_zone           = var.availability_zone           # Availability zone for the instances
  subnet_id                   = var.subnet_id                   # Subnet ID for the instances
  vpc_security_group_ids      = [module.security_group.security_group_id] # Security group IDs for the instances
  iam_instance_profile_name   = module.ec2_admin_role.instance_profile_name # IAM instance profile name
  launch_template             = var.launch_template             # Launch template for the instances
  enclave_options_enabled     = var.enclave_options_enabled     # Enable enclave options
  user_data_base64            = base64encode(local.user_data)   # Base64 encoded user data
  # user_data_replace_on_change = var.user_data_replace_on_change # Replace user data on change
  network_interface           = var.network_interface           # Network interface configuration
  root_block_device           = var.root_block_device           # Root block device configuration

  # Configuration for additional EBS block devices
  ebs_block_device = var.ebs_block_device # Additional EBS block devices

  tags = merge(var.default_tags, var.additional_tags) # Tags to be applied to the instances
}

# Module for creating an EC2 administrator role
module "ec2_admin_role" {
  source = "../../iam" # Adjust this path based on your directory structure

  role_name            = "ec2-admin-role"          # Role name
  role_description     = "EC2 administrator role with S3 access" # Role description
  max_session_duration = "7200"                    # Maximum session duration

  # Trust policy for EC2 service
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # Attach AWS managed policies
  policy_attachments = {
    AmazonEC2FullAccess    = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    AmazonS3ReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  # Add inline policies
  inline_policies = {
    "ssm-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ]
          Resource = ["arn:aws:ssm:*:*:parameter/app/*"]
        }
      ]
    })
  }

  # Create instance profile
  instance_profile_name = "ec2-admin-profile" # Instance profile name

  tags = {
    CostCenter  = "1234"       # Cost center tag
    MFCEnv      = "PROD"       # Environment tag
    Provisioner = "Terraform"  # Provisioner tag
    Purpose     = "EC2 testing" # Purpose tag
  }
}

# Module for creating a security group
module "security_group" {
  source = "../../sg" # Path to the security group module

  security_group_name        = "awlapptubormapp01-sg" # Security group name
  security_group_description = "Example security group" # Security group description
  vpc_id                     = "vpc" # VPC ID

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS traffic"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  security_group_tags = {
    Name        = "awlappsutrb01-sg" # Security group name tag
    Environment = "dev"        # Environment tag
  }
}
