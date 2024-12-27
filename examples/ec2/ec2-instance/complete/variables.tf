## Terraform AWS Provider Module variables############################################
######################################################################################

##*************************************************************************##
# Primary AWS region for the provider
variable "region" {
  description = "The AWS region to be used by the primary provider. Example: us-east-1, us-west-2."
  type        = string
  default     = "ca-central-1"
}

# AWS CLI profile for authentication with the primary provider
variable "profile" {
  description = "The AWS CLI profile to use for the primary provider. This profile must be configured in your AWS CLI credentials file."
  type        = string
  default     = "default"
}

# Secondary AWS region for the provider (optional)
variable "secondary_region" {
  description = "The secondary AWS region to be used by the secondary provider. Leave null if not using a secondary provider."
  type        = string
  default     = null
}

# AWS CLI profile for authentication with the secondary provider (optional)
variable "secondary_profile" {
  description = "The AWS CLI profile to use for the secondary provider. Leave null if not using a secondary provider."
  type        = string
  default     = null
}

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
  type = map(string)
  default = {
    Environment = "dev"
    Team        = "DevOps"
    Project     = "GB-GPM"
  }
}



# Variable: name
# Specifies the name to be used for the EC2 instance.
# Default: "default-ec2-instance"
# Example: "my-ec2-instance"
# Constraints:
# - Must not exceed 256 characters.

variable "name" {
  description = "Name to be used for the EC2 instance. This will be added as a 'Name' tag for identification."
  type        = string
  default     = "awlapturbonapp01"
  validation {
    condition     = length(var.name) <= 256
    error_message = "The 'name' must not exceed 256 characters."
  }
}


# Variable: ami
# Specifies the AMI ID to use for the instance.
# Default: null
# Example: "ami-0c55b159cbfafe1f0"
# Constraints:
# - Must either be null or a valid AMI ID starting with "ami-".

variable "ami" {
  description = "AMI ID to use for the instance. If not provided, it defaults to null and uses the SSM parameter defined in 'ami_ssm_parameter'."
  type        = string
  default     = null
  validation {
    condition     = var.ami == null || can(regex("^ami-[a-z0-9]+$", var.ami))
    error_message = "The 'ami' must either be null or a valid AMI ID starting with 'ami-'."
  }
}

# Define the variable for the number of instances to create
variable "instance_count" {
  description = "Number of instances to create"  # Description of the variable
  type        = number  # The type of the variable is a number
  default     = 1  # Default value is set to 1

  # Validation block to ensure the instance count is within a specified range
  validation {
    # Condition to check if the instance count is between 1 and 10 (inclusive)
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    # Error message to display if the condition is not met
    error_message = "The instance count must be between 1 and 10."
  }
}



# Variable: instance_type
# Specifies the type of instance to start.
# Default: "t3.micro"
# Example: "m5.large"
# Constraints:
# - Must be a valid EC2 instance type.

variable "instance_type" {
  description = "The type of the EC2 instance to launch in the Auto Scaling Group. Cannot be used with `instance_requirements`."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium", "m5.large", "m5.xlarge", "c5.2xlarge"], var.instance_type)
    error_message = "The instance type must be one of the following: t2.micro, t2.small, t2.medium, m5.large, m5.xlarge."
  }
}


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

# Variable: vpc_security_group_ids
# Specifies the security group IDs to associate with the instance.
# Default: []
# Example: ["sg-12345678", "sg-87654321"]

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
}



# Variable: create_eip
# Determines whether to create and associate an Elastic IP.
# Default: false
# Example: true

variable "create_eip" {
  description = "Whether to create and associate an Elastic IP."
  type        = bool
  default     = false
}

# Variable: disable_api_stop
# Determines whether to disable API stop for the EC2 instance.
# Default: false
# Example: false

variable "disable_api_stop" {
  description = "Whether to disable API stop for the instance."
  type        = bool
  default     = false
}

# Variable: create_iam_instance_profile
# Determines whether to create an IAM instance profile for the EC2 instance.
# Default: false
# Example: true

variable "create_iam_instance_profile" {
  description = "Whether to create an IAM instance profile for the instance."
  type        = bool
  default     = false
}

# Variable: iam_role_description
# Specifies the description of the IAM role to attach to the instance.
# Default: ""
# Example: "IAM role for EC2 instance"

variable "iam_role_description" {
  description = "Description of the IAM role."
  type        = string
  default     = ""
}

# Variable: iam_role_policies
# Specifies IAM policies to attach to the IAM role.
# Default: {}
# Example: { "AdministratorAccess" = "arn:aws:iam::aws:policy/AdministratorAccess" }

variable "iam_role_policies" {
  description = "A map of IAM policies to attach to the role."
  type        = map(string)
  default     = {}
}

# Variable: hibernation
# Determines whether to enable hibernation for the EC2 instance.
# Default: false
# Example: true

variable "hibernation" {
  description = "Whether hibernation is enabled for the instance."
  type        = bool
  default     = false
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

variable "user_data_base64" {
  description = "Base64 encoded user data for the instance."
  type        = string
  default     = ""
}

# Variable: user_data_replace_on_change
# Determines whether to replace the instance when user data changes.
# Default: false
# Example: true

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user data changes."
  type        = bool
  default     = false
}



# Variable: enable_volume_tags
# Determines whether to enable tags for EBS volumes attached to the instance.
# Default: false
# Example: true

variable "enable_volume_tags" {
  description = "Whether to enable volume tags."
  type        = bool
  default     = false
}

# Variable: root_block_device_encrypted
# Specifies whether the root block device is encrypted.
# Default: true
# Example: true

variable "root_block_device_encrypted" {
  description = "Whether the root block device is encrypted."
  type        = bool
  default     = true
}

# Variable: root_block_device_volume_type
# Specifies the volume type of the root block device.
# Default: "gp3"
# Example: "io1"

variable "root_block_device_volume_type" {
  description = "The volume type of the root block device."
  type        = string
  default     = "gp3"
}

# Variable: root_block_device_throughput
# Specifies the throughput for the root block device.
# Default: 125
# Example: 200

variable "root_block_device_throughput" {
  description = "The throughput for the root block device."
  type        = number
  default     = 125
}

# Variable: root_block_device_volume_size
# Specifies the size of the root block device in GB.
# Default: 50
# Example: 100

variable "root_block_device_volume_size" {
  description = "The size of the root block device."
  type        = number
  default     = 50
}

# Variable: root_block_device_tags
# Specifies tags to apply to the root block device.
# Default: {}
# Example: { "Name" = "root-volume" }

variable "root_block_device_tags" {
  description = "Tags to apply to the root block device."
  type        = map(string)
  default     = {}
}

# Variable: ebs_block_device_device_name
# Specifies the device name for the EBS block device.
# Default: "/dev/xvdf"
# Example: "/dev/sdf"

variable "ebs_block_device_device_name" {
  description = "The device name for the EBS block device."
  type        = string
  default     = "/dev/xvdf"
}

# Variable: ebs_block_device_volume_type
# Specifies the volume type for the EBS block device.
# Default: "gp3"
# Example: "io1"

variable "ebs_block_device_volume_type" {
  description = "The volume type of the EBS block device."
  type        = string
  default     = "gp3"
}

# Variable: ebs_block_device_volume_size
# Specifies the size of the EBS block device in GB.
# Default: 10
# Example: 20

variable "ebs_block_device_volume_size" {
  description = "The size of the EBS block device."
  type        = number
  default     = 10
}

# Variable: ebs_block_device_throughput
# Specifies the throughput for the EBS block device in MiB/s.
# Default: 125
# Example: 200

variable "ebs_block_device_throughput" {
  description = "The throughput for the EBS block device."
  type        = number
  default     = 125
}

# Variable: ebs_block_device_encrypted
# Specifies whether the EBS block device is encrypted.
# Default: true
# Example: true

variable "ebs_block_device_encrypted" {
  description = "Whether the EBS block device is encrypted."
  type        = bool
  default     = true
}

# Variable: ebs_block_device_kms_key_id
# Specifies the KMS key ID for the EBS block device encryption.
# Default: ""
# Example: "arn:aws:kms:region:account-id:key/key-id"

variable "ebs_block_device_kms_key_id" {
  description = "The KMS key ID for the EBS block device."
  type        = string
  default     = ""
}

# Variable: ebs_block_device_tags
# Specifies tags to apply to the EBS block device.
# Default: {}
# Example: { "MountPoint" = "/mnt/data" }

variable "ebs_block_device_tags" {
  description = "Tags to apply to the EBS block device."
  type        = map(string)
  default     = {}
}

variable "ebs_block_device" {
  description = "List of EBS block devices to attach to the instance."
  type = list(object({
    delete_on_termination = optional(bool, true)
    device_name           = string
    encrypted             = optional(bool, false)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    volume_size           = number
    volume_type           = string
    throughput            = optional(number)
    tags                  = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for device in var.ebs_block_device : 
      device.volume_size > 0 &&
      contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], device.volume_type) &&
      (device.throughput == null || device.throughput > 0) &&
      (device.encrypted == null || device.encrypted == true || device.encrypted == false)
    ])
    error_message = "Each EBS block device must have a positive volume size, a valid volume type (e.g., gp2, gp3), optional positive IOPS and throughput, and optional boolean encryption."
  }
}


# Variable: tags
# Specifies tags to apply to the EC2 instance and related resources.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "DevOps" }

variable "tags" {
  description = "Tags to apply to the EC2 instance."
  type        = map(string)
  default     = {}
}








# Variable: ephemeral_block_device
# Specifies ephemeral block devices for the instance.
# Default: []
# Example: [
#   {
#     device_name  = "/dev/xvdc"
#     virtual_name = "ephemeral0"
#   }
# ]

variable "ephemeral_block_device" {
  description = <<EOT
Customize ephemeral (also known as instance store) volumes on the instance.
These are temporary storage devices available for certain instance types.
EOT
  type    = list(object({
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
# Example: [
#   {
#     device_index         = 0
#     network_interface_id = "eni-12345678"
#   }
# ]

variable "network_interface" {
  description = <<EOT
Customize network interfaces to be attached at instance boot time.
This includes attributes such as device index, subnet ID, and security groups.
EOT
  type    = list(map(string))
  default = []
}


#################################Security Group#######################################################


variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "security_group_description" {
  description = "The description of the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}


variable "provider_name" {
  description = "Name of the provider"
  type        = string
}

variable "os_name" {
  description = "Name of the operating system"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
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
  type = map(object({
    ami              = string
    instance_type    = string
    key_name         = string
    additional_tags  = optional(map(string))
  }))
}

variable "server_type" {
  description = "Type of server to create"
  type        = string
  default     = "ap"
}

# Variable: iam_instance_profile
# Specifies the IAM Instance Profile to use.
# Default: null
# Example: "my-instance-profile"

variable "iam_instance_profile" {
  description = <<EOT
IAM Instance Profile to launch the instance with.
This is specified as the name of the Instance Profile.
EOT
  type    = string
  default = null
}

variable "root_volume_tags" {
  description = "A mapping of tags to assign to the root volumes created by the instance at launch time."
  type        = map(string)
  default     = {
    "Environment" = "Production"
    "Team"        = "RootStorage"
  }

  validation {
    condition = alltrue([
      for key, value in var.root_volume_tags : 
      can(regex("^[a-zA-Z0-9-_]+$", key)) && 
      can(regex("^[a-zA-Z0-9-_ ]+$", value))
    ])
    error_message = "Each tag key must only contain alphanumeric characters, hyphens, and underscores. Each tag value must only contain alphanumeric characters, hyphens, underscores, and spaces."
  }
}

variable "ebs_volume_tags" {
  description = "A mapping of tags to assign to the EBS volumes created by the instance at launch time."
  type        = map(string)
  default     = {
    "Environment" = "Production"
    "Team"        = "EBSStorage"
  }

  validation {
    condition = alltrue([
      for key, value in var.ebs_volume_tags : 
      can(regex("^[a-zA-Z0-9-_]+$", key)) && 
      can(regex("^[a-zA-Z0-9-_ ]+$", value))
    ])
    error_message = "Each tag key must only contain alphanumeric characters, hyphens, and underscores. Each tag value must only contain alphanumeric characters, hyphens, underscores, and spaces."
  }
}
