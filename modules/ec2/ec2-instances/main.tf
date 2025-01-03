# Define the AWS partition data source to get the current partition details
data "aws_partition" "current" {}

locals {
  ebs-device-id = 00
  iam_role_name = var.iam_role_name  # IAM role name
  provider_name = "aw"
  server_type = "ap"
  environment_name = "p"
  instance_names = {
    for k, v in var.instances : k => join("", [local.provider_name, var.os_family, local.server_type, local.environment_name, var.purpose, format("%02d", k + 1)])
  }
}

###### Security Group Creation ######################################################

# Create a security group
resource "aws_security_group" "sg" {
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

resource "aws_instance" "ec2" {
  # Basic instance properties
  for_each = { for idx, instance in var.instances : idx => instance }

  ami = each.value.ami
  instance_type = each.value.instance_type
  key_name = each.value.key_name

  # Tags with Naming Convention  
  tags = merge(
    { Name = local.instance_names[each.key] },
    each.value.additional_tags
  )

  user_data                   = var.user_data  # User data script to run on instance launch
  user_data_base64            = var.user_data_base64  # Base64 encoded user data
  user_data_replace_on_change = var.user_data_replace_on_change  # Replace user data on change
  availability_zone           = var.availability_zone  # Availability zone for the instance
  subnet_id                   = element(var.subnet_id, 0)  # Subnet ID for the instance
  vpc_security_group_ids      = [aws_security_group.sg.id]  # Security group IDs for the instance
  monitoring                  = var.monitoring  # Enable detailed monitoring
  get_password_data           = var.get_password_data  # Retrieve Windows password data
  #iam_instance_profile        = var.iam_instance_profile  # Use existing IAM instance profile
  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.iam_instance_profile[0].name : var.iam_instance_profile_name  # Use existing or newly created IAM instance profile
  private_ip                  = var.private_ip  # Private IP address
  secondary_private_ips       = var.secondary_private_ips  # Secondary private IP addresses

  # EBS Optimized was enabled default true as per Checkov Recommendation
  ebs_optimized = var.ebs_optimized  # Enable EBS optimization

  # Define dynamic blocks for root block device
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
      tags = {
        Name = "EBS-OS-USE-${local.instance_names[each.key]}-root-volume-${each.key + 1}"
        ebs_volume_id = "${each.key + 1}"
        ebs_volume_size = "${root_block_device.value.volume_size}GB"
      }
    }
  }

  # Define dynamic blocks for EBS block devices
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = try(ebs_block_device.value.encrypted, null)
      iops                  = try(ebs_block_device.value.iops, null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      volume_size           = try(ebs_block_device.value.volume_size, null)
      volume_type           = try(ebs_block_device.value.volume_type, null)
      throughput            = try(ebs_block_device.value.throughput, null)

      tags = {
        Name            = "EBS-OS-USE-${local.instance_names[each.key]}-ebs-volume-${format("%02d", each.key + 1)}"
        ebs_volume_id   = format("%02d", each.key + 1)
        ebs_volume_size = "${ebs_block_device.value.volume_size}GB"
      }
    }
  }

  # Define dynamic blocks for ephemeral block devices

dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = network_interface.value.network_interface_id
      delete_on_termination = network_interface.value.delete_on_termination
    }
}

  # Enforce metadata access via IMDsv2 enforced
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

  # Define instance level policies 
  source_dest_check                    = length(var.network_interface) > 0 ? null : var.source_dest_check  # Source/destination check
  disable_api_termination              = var.disable_api_termination  # Disable API termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior  # Instance initiated shutdown behavior
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
  tags_all = merge(var.default_tags, var.additional_tags)
}

################################################################################
# IAM Role / Instance Profile
################################################################################

# Check if the IAM role exists
data "aws_iam_role" "existing_role" {
  count = var.create_iam_role ? 0 : 1
  name  = var.iam_role_name
}

# Create the IAM role if it doesn't exist
resource "aws_iam_role" "iam_role" {
  count = var.create_iam_role ? 1 : 0
  name  = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, var.iam_role_tags)
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "iam_policy_attachment" {
  for_each = var.iam_role_policies

  role = var.create_iam_role ? aws_iam_role.iam_role[0].name : (
    length(data.aws_iam_role.existing_role) > 0 ? data.aws_iam_role.existing_role[0].name : null
  )

  policy_arn = each.value

  lifecycle {
    ignore_changes = [role]
  }
}

# Create the IAM instance profile
resource "aws_iam_instance_profile" "iam_instance_profile" {
  count = var.create_iam_role ? 1 : 0
  name  = var.iam_instance_profile_name
  role  = aws_iam_role.iam_role[0].name

  tags = merge(var.tags, var.iam_role_tags)
}
