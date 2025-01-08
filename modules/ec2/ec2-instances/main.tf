#tflint-ignore: terraform_required_version, 
# Define the AWS partition data source to get the current partition details

locals {
  module_metadata = {
    module_name    = "ec2"
    module_version = "v1.0.0"
  }
  ##Below local variables are hard coded as per Manulife Namining convention standards
  
  provider_name    = "aw"
  server_type      = "ap"
  environment_name = "p"
  instance_names = {
    for k, v in var.instances : k => join("", [local.provider_name, var.os_family, local.server_type, local.environment_name, var.purpose, format("%02d", k + 1)])
  }

}

module "resource_settings" {
  source      = "../../../../tools/resource_settings"
  cost_center = var.cost_center
  environment = var.environment
   module_name    = local.module_metadata.module_name
   module_version = local.module_metadata.module_version
 

}

################################################################################
# Instance
################################################################################

#tflint-ignore: terraform_required_providers
resource "aws_instance" "ec2" {
  # Basic instance properties
  for_each = { for idx, instance in var.instances : idx => instance }

 ami = length(var.launch_template) > 0 ? null : each.value.ami
 instance_type = length(var.launch_template) > 0 ? null : each.value.instance_type
  key_name      = each.value.key_name

  # Tags with Naming Convention  
  tags = merge(
    { Name = local.instance_names[each.key] },
    each.value.additional_tags, module.resource_settings.tags, module.resource_settings.default_tags, var.tags
  )

  user_data                   = var.user_data                                       # User data script to run on instance launch
  user_data_base64            = var.user_data_base64                                # Base64 encoded user data
  user_data_replace_on_change = var.user_data_replace_on_change                     # Replace user data on change
  availability_zone           = var.availability_zone                               # Availability zone for the instance
  subnet_id                   = element(var.subnet_id, 0)                           # Subnet ID for the instance   
  vpc_security_group_ids = var.vpc_security_group_ids                               # Security group IDs for the instance
  monitoring                  = var.monitoring                                      # Enable detailed monitoring
  get_password_data           = var.get_password_data                               # Retrieve Windows password data
  iam_instance_profile   =      var.iam_instance_profile_name                       # Use existing or newly created IAM instance profile
  private_ip                  = var.private_ip                                      # Private IP address
  secondary_private_ips       = var.secondary_private_ips                           # Secondary private IP addresses

  # EBS Optimized was enabled default true as per Checkov
  ebs_optimized = var.ebs_optimized # Enable EBS optimization

  # Define dynamic blocks for root block device
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = try(root_block_device.value.delete_on_termination, null) # Delete on termination
      encrypted             = try(root_block_device.value.encrypted, null)             # Encryption
      iops                  = try(root_block_device.value.iops, null)                  # IOPS
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)      # KMS key ID
      volume_size           = try(root_block_device.value.volume_size, null)           # Volume size
      volume_type           = try(root_block_device.value.volume_type, null)           # Volume type
      throughput            = try(root_block_device.value.throughput, null)            # Throughput
      tags = {
        Name            = "EBS-OS-USE-${local.instance_names[each.key]}-root-volume-${format("%02d", each.key + 1)}"
        ebs_volume_id   = format("%02d", each.key + 1)
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
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")       # HTTP endpoint
      http_tokens                 = try(metadata_options.value.http_tokens, "required")        # HTTP tokens
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 1) # HTTP PUT response hop limit
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)   # Instance metadata tags
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
      hostname_type                        = try(private_dns_name_options.value.hostname_type, null)                        # Hostname type
      enable_resource_name_dns_a_record    = try(private_dns_name_options.value.enable_resource_name_dns_a_record, null)    # Enable DNS A record
      enable_resource_name_dns_aaaa_record = try(private_dns_name_options.value.enable_resource_name_dns_aaaa_record, null) # Enable DNS AAAA record
    }
  }

  # Define dynamic blocks for launch templates
  dynamic "launch_template" {
    for_each = length(var.launch_template) > 0 ? [var.launch_template] : []

    content {
      id      = lookup(var.launch_template, "id", null)      # Launch template ID
      name    = lookup(var.launch_template, "name", null)    # Launch template name
      version = lookup(var.launch_template, "version", null) # Launch template version
    }
  }

  # Define dynamic blocks for maintenance options
  dynamic "maintenance_options" {
    for_each = length(var.maintenance_options) > 0 ? [var.maintenance_options] : []

    content {
      auto_recovery = try(maintenance_options.value.auto_recovery, null) # Auto recovery
    }
  }

  # Define enclave options
  enclave_options {
    enabled = var.enclave_options_enabled # Enable enclave options
  }

  # Define instance level policies 
  source_dest_check                    = length(var.network_interface) > 0 ? null : var.source_dest_check # Source/destination check
  disable_api_termination              = var.disable_api_termination                                      # Disable API termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior                         # Instance initiated shutdown behavior
  tenancy                              = var.tenancy                                                      # Tenancy
  host_id                              = var.host_id                                                      # Host ID
  # Define timeouts for instance creation, update, and deletion
  timeouts {
    create = try(var.timeouts.create, null) # Creation timeout
    update = try(var.timeouts.update, null) # Update timeout
    delete = try(var.timeouts.delete, null) # Deletion timeout
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes = [
      root_block_device,
      ebs_block_device
    ]
  }

  # Define tags for the instance and volumes
  tags_all = merge(var.default_tags, var.additional_tags)
}

