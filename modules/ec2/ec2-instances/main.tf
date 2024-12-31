# Define the AWS partition data source to get the current partition details
data "aws_partition" "current" {}



######Security Group Creation######################################################

# Create a security group
resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = var.security_group_tags
}



################################################################################
# Instance
################################################################################

resource "aws_instance" "this" {


 #Basicinstance Properties
 for_each = var.instances
     
  ami = each.value.ami 
  instance_type = each.value.instance_type 
  key_name = each.value.key_name 
  # Tags with Naming Convention 
  #tags = merge( { Name = join("", [ var.provider_name, var.os_family, var.server_type, var.environment_name, var.purpose, each.key ]) }) 
  tags                        = merge(
                                  { Name = join("", [var.provider_name, var.os_family, var.server_type, var.environment_name, var.purpose, format("%02d", each.key + 1)]) },
                                  each.value.additional_tags )
  
  hibernation          = var.hibernation  # Enable hibernation for the instance
  user_data                   = var.user_data  # User data script to run on instance launch
  user_data_base64            = var.user_data_base64  # Base64 encoded user data
  user_data_replace_on_change = var.user_data_replace_on_change  # Replace user data on change
  availability_zone           = var.availability_zone  # Availability zone for the instance
  subnet_id                   = element(var.subnet_id, 0)  # Subnet ID for the instance
  vpc_security_group_ids      = [aws_security_group.this.id]  # Security group IDs for the instance
  monitoring           = var.monitoring  # Enable detailed monitoring
  get_password_data    = var.get_password_data  # Retrieve Windows password data
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile  # IAM instance profile
  associate_public_ip_address = var.associate_public_ip_address  # Associate a public IP address is restricted as per THR 
  private_ip                  = var.private_ip  # Private IP address
  secondary_private_ips       = var.secondary_private_ips  # Secondary private IP addresses
  # Choose between ipv6_address_count or ipv6_addresses
  ipv6_address_count = var.ipv6_address_count != null ? var.ipv6_address_count : null  # Number of IPv6 addresses
  ipv6_addresses     = var.ipv6_addresses != null && length(var.ipv6_addresses) > 0 ? var.ipv6_addresses : null  # List of IPv6 addresses
  ebs_optimized = var.ebs_optimized  # Enable EBS optimization

  # Define dynamic blocks for root block devices
  #Encrypt the root block devices --> THR
  dynamic "root_block_device" {
    for_each = var.root_block_device

    content {
      delete_on_termination = try(root_block_device.value.delete_on_termination, null)  # Delete on termination
      encrypted             = try(root_block_device.value.encrypted, null)  # Encryption
      iops                  = try(root_block_device.value.iops, null)  # IOPS
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)  # KMS key ID
      volume_size           = try(root_block_device.value.volume_size, null)  # Volume size
      volume_type           = try(root_block_device.value.volume_type, null)  # Volume type
      throughput            = try(root_block_device.value.throughput, null)  # Throughput
      tags                 = try(root_block_device.value.root_block_device_tags, null)  # Tags
      #tags                  = merge(var.root_block_device_tags, var.additional_tags, var.default_tags)
    }
  }

  # Define dynamic blocks for EBS block devices
  #Encrypt the additional EBS Block Devices --> THR
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device

    content {
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, null)  # Delete on termination
      device_name           = ebs_block_device.value.device_name  # Device name
      encrypted             = try(ebs_block_device.value.encrypted, null)  # Encryption
      iops                  = try(ebs_block_device.value.iops, null)  # IOPS
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)  # KMS key ID
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)  # Snapshot ID
      volume_size           = try(ebs_block_device.value.volume_size, null)  # Volume size
      volume_type           = try(ebs_block_device.value.volume_type, null)  # Volume type
      throughput            = try(ebs_block_device.value.throughput, null)  # Throughput
      tags                 = try(ebs_block_device.value.ebs_block_device_tags, null)  # Tags
    
    }
  }

  # Define dynamic blocks for ephemeral block devices
  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device

    content {
      device_name  = ephemeral_block_device.value.device_name  # Device name
      no_device    = try(ephemeral_block_device.value.no_device, null)  # No device
      virtual_name = try(ephemeral_block_device.value.virtual_name, null)  # Virtual name
    }
  }
  #Enforce metadata access via IMDsv2 enforced --> THR
  # Define dynamic blocks for metadata options
  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")  # HTTP endpoint
      http_tokens                 = try(metadata_options.value.http_tokens, "required")  # HTTP tokens
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 1)  # HTTP PUT response hop limit
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)  # Instance metadata tags
    }
  }



# Define dynamic blocks for network interfaces

dynamic "network_interface" {
  for_each = var.network_interface


  content {
    device_index          = network_interface.value.device_index
    network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
    delete_on_termination = try(network_interface.value.delete_on_termination, false)
        # Adding tags to the network interface


  }
}

  # Define dynamic blocks for private DNS name options
  dynamic "private_dns_name_options" {
    for_each = length(var.private_dns_name_options) > 0 ? [var.private_dns_name_options] : []

    content {
      hostname_type                        = try(private_dns_name_options.value.hostname_type, null)  # Hostname type
      enable_resource_name_dns_a_record    = try(private_dns_name_options.value.enable_resource_name_dns_a_record, null)  # Enable DNS A record
      enable_resource_name_dns_aaaa_record = try(private_dns_name_options.value.enable_resource_name_dns_aaaa_record, null)  # Enable DNS AAAA record
    }
  }

  # Define dynamic blocks for launch templates
  dynamic "launch_template" {
    for_each = length(var.launch_template) > 0 ? [var.launch_template] : []

    content {
      id      = lookup(var.launch_template, "id", null)  # Launch template ID
      name    = lookup(var.launch_template, "name", null)  # Launch template name
      version = lookup(var.launch_template, "version", null)  # Launch template version
    }
  }
 
  # Define dynamic blocks for maintenance options
  dynamic "maintenance_options" {
    for_each = length(var.maintenance_options) > 0 ? [var.maintenance_options] : []

    content {
      auto_recovery = try(maintenance_options.value.auto_recovery, null)  # Auto recovery
    }
  }

  # Define enclave options
  enclave_options {
    enabled = var.enclave_options_enabled  # Enable enclave options
  }

  # Define  instance level policies 
  source_dest_check                    = length(var.network_interface) > 0 ? null : var.source_dest_check  # Source/destination check
  disable_api_termination              = var.disable_api_termination  # Disable API termination
  # disable_api_stop                     = var.disable_api_stop  # Disable API stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior  # Instance initiated shutdown behavior
  # placement_group                      = var.placement_group  # Placement group
  tenancy                              = var.tenancy  # Tenancy
  host_id                              = var.host_id  # Host ID

  # Define timeouts for instance creation, update, and deletion
  timeouts {
    create = try(var.timeouts.create, null)  # Creation timeout
    update = try(var.timeouts.update, null)  # Update timeout
    delete = try(var.timeouts.delete, null)  # Deletion timeout
  }

    lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [
      root_block_device,
      ebs_block_device
    ]
  }

  # Define tags for the instance and volumes
  tags_all =  merge(var.default_tags, var.root_block_device_tags, var.ebs_block_device_tags, var.additional_tags)

}

################################################################################
# IAM Role / Instance Profile
################################################################################

locals {
  iam_role_name = try(coalesce(var.iam_role_name, var.name), "")  # IAM role name
}
# Define the IAM policy document for assuming the role
data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_instance_profile ? 1 : 0  # Create policy document only if IAM instance profile is to be created

  statement {
    sid     = "EC2AssumeRole"  # Statement ID
    actions = ["sts:AssumeRole"]  # Actions allowed

    principals {
      type        = "Service"  # Principal type
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]  # Service principal (EC2)
    }
  }
}

# Define the IAM role resource
resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0  # Create IAM role only if IAM instance profile is to be created

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name  # IAM role name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null  # IAM role name prefix
  path        = var.iam_role_path  # IAM role path
  description = var.iam_role_description  # IAM role description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json  # Assume role policy
  permissions_boundary  = var.iam_role_permissions_boundary  # Permissions boundary
  force_detach_policies = true  # Force detach policies

  tags = merge(var.tags, var.iam_role_tags)  # Tags for the IAM role
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.iam_role_policies : k => v if var.create_iam_instance_profile }  # Iterate over IAM role policies
  policy_arn = each.value  # Policy ARN
  role       = aws_iam_role.this[0].name  # IAM role name
}

# Define the IAM instance profile resource
resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0  # Create IAM instance profile only if specified
  role = aws_iam_role.this[0].name  # IAM role name
  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name  # Instance profile name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null  # Instance profile name prefix
  path        = var.iam_role_path  # Instance profile path
  tags = merge(var.tags, var.iam_role_tags)  # Tags for the instance profile

  lifecycle {
    create_before_destroy = true  # Ensure new instance profile is created before destroying the old one


  }
}


/*
# CloudWatch Log Group for EC2 instance logs
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/instance-logs"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# CloudWatch Log Stream for EC2 instance logs
resource "aws_cloudwatch_log_stream" "ec2_stream" {
  name           = "instance-log-stream"
  log_group_name = aws_cloudwatch_log_group.ec2_logs.name
}

# SSM Document for enabling logging on EC2 instances
resource "aws_ssm_document" "enable_logging" {
  name          = "EnableInstanceLogging"
  document_type = "Command"
  content       = var.ssm_logging_document_content
  tags          = var.tags
}


# GuardDuty for Threat Protection
resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0
  enable = true
}
resource "aws_securityhub_standards_subscription" "best_practices" {
  count        = var.enable_securityhub ? 1 : 0
  standards_arn = "arn:aws:securityhub:::standards/aws-foundational-security-best-practices/v/1.0.0"
}
*/
