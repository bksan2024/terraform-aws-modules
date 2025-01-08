# tflint-ignore: all

## Terraform AWS Provider Module variables############################################
######################################################################################

##*************************************************************************##
# Primary AWS region for the provider
variable "region" {
  description = "The AWS region to be used by the primary provider. Example: us-east-1, us-west-2."
  type        = string
  default     = "ca-central-1"
}

#AWS CLI profile for authentication with the primary provider
variable "profile" {
  description = "The AWS CLI profile to use for the primary provider. This profile must be configured in your AWS CLI credentials file."
  type        = string
  default     = "default"
}

# Secondary AWS region for the provider (optional)
# tflint-ignore: all
# variable "secondary_region" {
#   description = "The secondary AWS region to be used by the secondary provider. Leave null if not using a secondary provider."
#   type        = string
#   default     = null
# }

# AWS CLI profile for authentication with the secondary provider (optional)
# variable "secondary_profile" {
#   description = "The AWS CLI profile to use for the secondary provider. Leave null if not using a secondary provider."
#   type        = string
#   default     = null
# }

# Default tags to apply to all resources managed by the providers
variable "default_tags" {
  description = <<EOT
A map of default tags to be applied to all resources. 
Tags are key-value pairs that help with resource identification, cost management, and access control.
Examples:
- Environment: dev, test, prod
- Team: DevOps, Security
- Project: your-project-name
EOT
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "DevOps"
    Project     = "GB-GPM"
  }
}






# Variable: ami
# Specifies the AMI ID to use for the instance.
# Default: null
# Example: "ami-0c55b159cbfafe1f0"
# Constraints:
# - Must either be null or a valid AMI ID starting with "ami-".

# variable "ami" {
#   description = "AMI ID to use for the instance. If not provided, it defaults to null and uses the SSM parameter defined in 'ami_ssm_parameter'."
#   type        = string
#   default     = null
#   validation {
#     condition     = var.ami == null || can(regex("^ami-[a-z0-9]+$", var.ami))
#     error_message = "The 'ami' must either be null or a valid AMI ID starting with 'ami-'."
#   }
# }







# Variable: availability_zone
# Specifies the Availability Zone (AZ) to start the instance in.
# Default: "ca-central-1"
# Example: "ca-central-1a"
# Constraints:
# - Must be a valid AWS Availability Zone string.

variable "availability_zone" {
  description = "Specifies the Availability Zone (AZ) to start the instance in. Defaults to 'ca-central-1a' for instances in Canada Central."
  type        = string
  default     = "ca-central-1a"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.availability_zone))
    error_message = "The 'availability_zone' must be a valid AWS Availability Zone string, such as 'us-east-1a' or 'ca-central-1a'."
  }
}

# Variable: subnet_id
# Specifies the subnet ID where the EC2 instance will be deployed.
# Default: null
# Example: "subnet-12345678"

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be deployed."
  type        = list(string)
}






# Variable: enclave_options_enabled
# Determines whether to enable enclave options for the EC2 instance.
# Default: false
# Example: false

variable "enclave_options_enabled" {
  description = "Whether enclave options are enabled for the instance."
  type        = bool
  default     = false
}

# Variable: user_data_base64
# Specifies base64-encoded user data for the instance.
# Default: ""
# Example: base64encode("#!/bin/bash\necho Hello World")

#tflint-ignore: all
variable "user_data_base64" {
  description = "Base64 encoded user data for the instance."
  type        = string
  default     = ""
}




# Variable: enable_volume_tags
# Determines whether to enable tags for EBS volumes attached to the instance.
# Default: false
# Example: true


variable "root_block_device" {
  description = <<EOT
Customize details about the root block device of the instance. 
Supports parameters such as size, type, IOPS, encryption, and tags.
EOT
  type = list(object({
    volume_size = number
    volume_type = string
    iops        = optional(number)
    encrypted   = optional(bool)
    tags        = optional(map(string))
  }))
  default = [
    {
      volume_size = 50
      volume_type = "gp3"
      iops        = 3000
    }
  ]

  validation {
    condition = alltrue([
      for device in var.root_block_device :
      device.volume_size > 0 &&
      contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], device.volume_type) &&
      (device.encrypted == null || device.encrypted == true || device.encrypted == false)
    ])
    error_message = "Each root block device must have a positive volume size, a valid volume type (e.g., gp2, gp3), optional positive IOPS, and optional boolean encryption."
  }
}





variable "ebs_block_device" {
  description = "Configuration for EBS block devices"
  type = list(object({
    delete_on_termination = bool
    device_name           = string
    encrypted             = bool
    iops                  = number
    kms_key_id            = string
    snapshot_id           = string
    volume_size           = number
    volume_type           = string
    throughput            = number
    tags                  = map(string)
  }))
}


# Variable: tags
# Specifies tags to apply to the EC2 instance and related resources.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "DevOps" }

#tflint-ignore: all
variable "tags" {
  description = "Tags to apply to the EC2 instance."
  type        = map(string)
  default     = {}
}




# Variable: ephemeral_block_device
# Specifies ephemeral block devices for the instance.


#tflint-ignore: all
variable "ephemeral_block_device" {
  description = <<EOT
Customize ephemeral (also known as instance store) volumes on the instance.
These are temporary storage devices available for certain instance types.
EOT
  type = list(object({
    device_name  = string
    virtual_name = string
  }))
  default = [
    {
      device_name  = "/dev/xvdc"
      virtual_name = "ephemeral0"
    }
  ]

  validation {
    condition = alltrue([
      for device in var.ephemeral_block_device :
      can(regex("^/dev/xvd[b-z]$", device.device_name)) &&
      can(regex("^ephemeral[0-9]+$", device.virtual_name))
    ])
    error_message = "Each block device must have a valid device name (e.g., /dev/xvdc) and a valid virtual name (e.g., ephemeral0)."
  }
}


# Variable: network_interface
# Specifies custom network interfaces to attach to the instance.
# Default: []


variable "network_interface" {
  description = "Configuration for network interfaces"
  default     = {}

  type = map(object({
    device_index          = number
    network_interface_id  = optional(string)
    delete_on_termination = optional(bool)
    additional_tags       = optional(map(string), {})
  }))
}




variable "purpose" {
  description = "Name of the application"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}

variable "instances" {
  description = "Map of instances to create"
  type = list(object({
    ami             = optional(string, null) # Optional AMI with default value null
    instance_type   = optional(string, null) # Optional instance type with default value null
    key_name        = optional(string, null) # Optional key name with default value null
    additional_tags = optional(map(string), {}) # Optional additional tags with default value empty map
  }))

  validation {
    condition = (
  (length(var.launch_template) == 0 && alltrue([for instance in var.instances : instance.ami != null])) ||
  (length(var.launch_template) != 0 && alltrue([for instance in var.instances : instance.ami == null]))
)
    error_message = "AMI should not be specified if a launch template is provided."
  }

}




variable "launch_template" {
  description = <<EOT
Specifies a Launch Template to configure the instance. 
Parameters configured on this resource will override the corresponding parameters in the Launch Template.
EOT
  type = list(object({
    id      = optional(string, null)   # Optional Launch Template ID
    name    = optional(string, null)   # Optional Launch Template name
    version = optional(string, null)   # Optional Launch Template version
  }))
}


variable "os_family" {
  description = "Operating system family for the instances"
  type        = string
}










