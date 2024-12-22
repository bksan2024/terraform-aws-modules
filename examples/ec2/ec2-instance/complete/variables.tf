## Terraform AWS Provider Module variables############################################
######################################################################################

# Variable: terraform_version
# Specifies the Terraform version constraint.
# Default: ">= 1.4.0"
# Example: ">= 1.4.0"

variable "terraform_version" {
  description = "Terraform version constraint. Specifies the minimum required version of Terraform to use."
  type        = string
  default     = ">= 1.4.0"
}

# Variable: provider_version
# Specifies the AWS provider version to use.
# Default: "~> 5.0"
# Example: "~> 5.0"

variable "provider_version" {
  description = "AWS provider version to use with Terraform. Ensure compatibility with your desired features and Terraform version."
  type        = string
  default     = "~> 5.0"
}

# Variable: region
# Specifies the AWS region for deploying resources.
# Default: "us-east-1"
# Example: "us-west-2"

variable "region" {
  description = "AWS region where resources will be deployed. Choose a region that meets latency, compliance, and availability requirements."
  type        = string
  default     = "us-east-1"
}

# Variable: assume_role_arn
# Specifies the ARN of the role to assume in AWS.
# Default: null
# Example: "arn:aws:iam::123456789012:role/example-role"

variable "assume_role_arn" {
  description = "ARN of the role to assume in AWS for cross-account access. Useful for managing resources in other AWS accounts."
  type        = string
  default     = null
}

# Variable: default_tags
# Specifies default tags for AWS resources.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "DevOps" }

variable "default_tags" {
  description = "A map of default tags to assign to all AWS resources created by Terraform. Helps in resource identification and organization."
  type        = map(string)
  default     = {}
}

# Variable: profile
# Specifies the AWS CLI profile to use for credentials.
# Default: "default"
# Example: "production-profile"

variable "profile" {
  description = "AWS CLI profile to use for authentication and credentials. Use profiles configured in your AWS credentials file."
  type        = string
  default     = "default"
}




# Variable: name
# Specifies the name of the EC2 instance.
# Default: null
# Example: "example-instance"

variable "name" {
  description = "The name of the EC2 instance."
  type        = string
}

# Variable: instance_type
# Specifies the type of EC2 instance to deploy.
# Default: null
# Example: "t2.micro"

variable "instance_type" {
  description = "The type of instance to deploy."
  type        = string
}

# Variable: availability_zone
# Specifies the availability zone for the EC2 instance.
# Default: null
# Example: "eu-west-1a"

variable "availability_zone" {
  description = "The availability zone to deploy the instance in."
  type        = string
}

# Variable: subnet_id
# Specifies the subnet ID where the EC2 instance will be deployed.
# Default: null
# Example: "subnet-12345678"

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be deployed."
  type        = string
}

# Variable: vpc_security_group_ids
# Specifies the security group IDs to associate with the instance.
# Default: []
# Example: ["sg-12345678", "sg-87654321"]

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
}

# Variable: placement_group
# Specifies the placement group name for the instance.
# Default: null
# Example: "placement-group-name"

variable "placement_group" {
  description = "The placement group name for the EC2 instance."
  type        = string
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

# Variable: cpu_core_count
# Sets the number of CPU cores for the instance.
# Default: null
# Example: 4
# Constraints:
# - Must be a positive integer.

variable "cpu_core_count" {
  description = <<EOT
Sets the number of CPU cores for the instance. 
This is only supported on instance types that support CPU options.
EOT
  type    = number
  default = null
  validation {
    condition     = var.cpu_core_count == null || var.cpu_core_count > 0
    error_message = "The 'cpu_core_count' must be null or a positive integer."
  }
}

# Variable: cpu_threads_per_core
# Sets the number of CPU threads per core for the instance.
# Default: null
# Example: 2
# Constraints:
# - Must be a positive integer.

variable "cpu_threads_per_core" {
  description = <<EOT
Sets the number of CPU threads per core for the instance. 
This has no effect unless `cpu_core_count` is also set.
EOT
  type    = number
  default = null
  validation {
    condition     = var.cpu_threads_per_core == null || var.cpu_threads_per_core > 0
    error_message = "The 'cpu_threads_per_core' must be null or a positive integer."
  }
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

# Variable: tags
# Specifies tags to apply to the EC2 instance and related resources.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "DevOps" }

variable "tags" {
  description = "Tags to apply to the EC2 instance."
  type        = map(string)
  default     = {}
}
