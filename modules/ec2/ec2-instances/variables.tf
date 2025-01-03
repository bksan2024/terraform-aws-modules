/*
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
*/


# Variable: ami
# Specifies the AMI ID to use for the instance.
# Default: null
# Example: "ami-0c55b159cbfafe1f0"
# Constraints:
# - Must either be null or a valid AMI ID starting with "ami-".

variable "ami" {
  description = "AMI ID to provision the rquired OS instance."
  type        = string
  default     = null
  validation {
    condition     = var.ami == null || can(regex("^ami-[a-z0-9]+$", var.ami))
    error_message = "The 'ami' must either be null or a valid AMI ID starting with 'ami-'."
  }
}


# Variable: maintenance_options
# Specifies the maintenance options for the instance.
# Default: { "auto_recovery" = "enabled" }
# Example: { "auto_recovery" = "enabled" }

variable "maintenance_options" {
  description = <<EOT
Defines the maintenance options for the instance.
Specify settings such as auto-recovery or custom maintenance windows.
EOT
  type    = map(any)
  default = { "auto_recovery" = "disabled" }
}

# Variable: availability_zone
# Specifies the Availability Zone (AZ) to start the instance in.
# Default: "ca-central-1"
# Example: "ca-central-1a"
# Constraints:
# - Must be a valid AWS Availability Zone string.

variable "availability_zone" {
  description = "Specifies the Availability Zone (AZ) to provision the instance in that specific AZ. Default is set to 'ca-central-1a'."
  type        = string
  default     = "ca-central-1a"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.availability_zone))
    error_message = "The 'availability_zone' must be a valid AWS Availability Zone string, such as 'us-east-1a' or 'ca-central-1a'."
  }
}


# Variable: disable_api_termination
# Enables EC2 Instance Termination Protection.
# Default: false
# Example: true

variable "disable_api_termination" {
  description = <<EOT
If true, enables EC2 Instance Termination Protection. This prevents accidental termination of the instance.
Defaults to 'false', ensuring easy management unless termination protection is explicitly required.
EOT
  type    = bool
  default = false
}

# Variable: ebs_block_device
# Specifies additional EBS block devices to attach to the instance.
# Default: []
# Example: [
#   {
#     device_name = "/dev/xvdb"
#     volume_type = "gp2"
#     volume_size = 100
#   }
# ]

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

# Variable: ebs_optimized
# Specifies if the EC2 instance should be EBS-optimized.
# Default: false
# Example: true

variable "ebs_optimized" {
  description = <<EOT
If true, the launched EC2 instance will be EBS-optimized, providing dedicated throughput for EBS volumes.
Defaults to 'true' to checkov complaince pass.
EOT
  type    = bool
  default = true

  validation {
    condition     = var.ebs_optimized == true || var.ebs_optimized == false
    error_message = "The ebs_optimized variable must be a boolean value (true or false)."
  }
}

# Variable: enclave_options_enabled
# Determines whether Nitro Enclaves are enabled.
# Default: false
# Example: false

variable "enclave_options_enabled" {
  description = <<EOT
Whether Nitro Enclaves will be enabled on the instance.
Nitro Enclaves provide an isolated environment for sensitive data processing.
Defaults to 'false'.
EOT
  type    = bool
  default = false

  validation {
    condition     = var.enclave_options_enabled == true || var.enclave_options_enabled == false
    error_message = "The enclave_options_enabled variable must be a boolean value (true or false)."
  }
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
  default = [ ]

}

# Variable: get_password_data
# Determines whether to wait and retrieve password data.
# Default: false
# Example: true

variable "get_password_data" {
  description = <<EOT
If true, wait for password data to become available and retrieve it.
This is typically used for Windows instances to retrieve the administrator password.
Defaults to 'false'.
EOT
  type    = bool
  default = false
}



# Variable: host_id
# Specifies the ID of a dedicated host for the instance.
# Default: null
# Example: "host-12345678"

variable "host_id" {
  description = <<EOT
ID of a dedicated host that the instance will be assigned to.
This is used for launching an instance on a specific dedicated host.
EOT
  type    = string
  default = null
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

# Variable: instance_initiated_shutdown_behavior
# Specifies the shutdown behavior for the instance.
# Default: "stop"
# Example: "terminate"
# Constraints:
# - Must be "stop" or "terminate".

variable "instance_initiated_shutdown_behavior" {
  description = <<EOT
Shutdown behavior for the instance.
Defaults to 'stop' for EBS-backed instances and 'terminate' for instance-store instances.
Cannot be set on instance-store instances.
EOT
  type    = string
  default = "stop"
  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "The 'instance_initiated_shutdown_behavior' must be 'stop' or 'terminate'."
  }
}

# Variable: instance_type
# Specifies the type of instance to start.
# Default: "t3.micro"
# Example: "m5.large"
# Constraints:
# - Must be a valid EC2 instance type.

variable "instance_type" {
  description = "The type of the EC2 instance to launch in AWS`."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium", "m5.large", "m5.2xlarge", "c5.2xlarge"], var.instance_type)
    error_message = "The instance type must be one of the following: t2.micro, t2.small, t2.medium, m5.large, m5.xlarge."
  }
}

/*
# Variable: instance_tags
# Specifies additional tags for the instance.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "DevOps" }

variable "instance_tags" {
  description = "Additional tags for the instance. These tags are merged with default tags."
  type        = map(string)
  default     = {
    "Environment" = "development"
    "Owner"       = "admin"
  }

  validation {
    condition     = alltrue([for key, value in var.instance_tags : can(regex("^[a-zA-Z0-9-_]+$", key)) && can(regex("^[a-zA-Z0-9-_ ]+$", value))])
    error_message = "Each tag key and value must only contain alphanumeric characters, hyphens, underscores, and spaces."
  }
}
*/

# Variable: key_name
# Specifies the key name for the instance.
# Default: null
# Example: "my-key-pair"
# Constraints:
# - Must be null or a valid key pair name (alphanumeric, dashes, underscores).

variable "key_name" {
  description = <<EOT
Key name of the Key Pair to use for the instance.
The Key Pair can be managed using the `key_pair` resource.
EOT
  type    = string
  default = null
  validation {
    condition     = var.key_name == null || can(regex("^[a-zA-Z0-9-_]+$", var.key_name))
    error_message = "The 'key_name' must be null or a valid key pair name consisting of alphanumeric characters, dashes, or underscores."
  }
}

# Variable: launch_template
# Specifies the launch template for the instance.
# Default: {}
# Example: { id = "lt-12345678", version = "1" }

variable "launch_template" {
  description = <<EOT
Specifies a Launch Template to configure the instance. 
Parameters configured on this resource will override the corresponding parameters in the Launch Template.
EOT
type = map(any)
}
# Variable: metadata_options
# Specifies the metadata options to be applied dynamically to the instances in the launch template.
# Default:
# {
#   "http_endpoint": "enabled",
#   "http_tokens": "required",
#   "http_put_response_hop_limit": 1,
#   "http_protocol_ipv6": "disabled",
#   "instance_metadata_tags": "disabled"
# }
# Example:
# {
#   "http_endpoint": "enabled",
#   "http_tokens": "required",
#   "http_put_response_hop_limit": 1,
#   "http_protocol_ipv6": "disabled",
#   "instance_metadata_tags": "enabled"
# }
# Constraints:
# - `http_endpoint` must be "enabled" or "disabled".
# - `http_tokens` must be either "required" or "optional".
# - `http_put_response_hop_limit` must be an integer between 1 and 64.
# - `http_protocol_ipv6` must be "enabled" or "disabled".
# - `instance_metadata_tags` must be "enabled" or "disabled".

variable "metadata_options" {
  description = "Specifies the metadata options EC2 instance with IMDSv2."
  type = map(string)
  default = {
    http_endpoint               = "enabled"    # Enables metadata service
    http_tokens                 = "required"   # Enforces IMDSv2
    http_put_response_hop_limit = "1"          # Restricts metadata response hops to 1
    http_protocol_ipv6          = "disabled"   # Disables IPv6 metadata requests
    instance_metadata_tags      = "disabled"   # Disables metadata tags
  }
  validation {
    condition = alltrue([
      can(regex("^(enabled|disabled)$", var.metadata_options["http_endpoint"])),
      can(regex("^(required|optional)$", var.metadata_options["http_tokens"])),
      var.metadata_options["http_put_response_hop_limit"] >= 1 && var.metadata_options["http_put_response_hop_limit"] <= 64,
      can(regex("^(enabled|disabled)$", var.metadata_options["http_protocol_ipv6"])),
      can(regex("^(enabled|disabled)$", var.metadata_options["instance_metadata_tags"]))
    ])
    error_message = "Invalid metadata_options: `http_endpoint`, `http_protocol_ipv6`, and `instance_metadata_tags` must be 'enabled' or 'disabled', `http_tokens` must be 'required' or 'optional', and `http_put_response_hop_limit` must be between 1 and 64."
  }
}


# Variable: monitoring
# Enables detailed monitoring for the instance.
# Default: true
# Example: true

variable "monitoring" {
  description = "launched EC2 instance will have detailed monitoring enabled or disabled."
  type        = bool
  default     = true

  validation {
    condition     = var.monitoring == true || var.monitoring == false
    error_message = "The monitoring variable must be a boolean value (true or false)."
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
  description = "network_interface variable allows you to configure network interfaces for your AWS EC2 instances. This variable is defined as a map of objects, where each object represents a network interface configuration"
  type = map(object({
    device_index          = number
    network_interface_id  = optional(string)
    delete_on_termination = optional(bool)
    additional_tags       = optional(map(string), {})
  }))
}


# Variable: private_dns_name_options
# Configures private DNS name options for the instance.
# Default: {}
# Example: { hostname_type = "ip-name", enable_resource_name_dns_a_record = true }

variable "private_dns_name_options" {
  description = "Customize the private DNS name options of the instance."
  type        = object({
    hostname_type                      = string
    enable_resource_name_dns_a_record  = bool
  })
  default = {
    hostname_type                     = "ip-name"
    enable_resource_name_dns_a_record = true
  }

  validation {
    condition = alltrue([
      contains(["ip-name", "resource-name"], lookup(var.private_dns_name_options, "hostname_type", "")),
      var.private_dns_name_options.enable_resource_name_dns_a_record == true || var.private_dns_name_options.enable_resource_name_dns_a_record == false
    ])
    error_message = "The private_dns_name_options must have a valid hostname_type (either 'ip-name' or 'resource-name') and enable_resource_name_dns_a_record must be a boolean value (true or false)."
  }
}


# Variable: private_ip
# Configures the private IP address for the instance.
# Default: null
# Example: "10.0.0.5"

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = null
}

# Variable: root_block_device
# Customizes the root block device for the instance.
# Default: []
# Example: [
#   {
#     volume_size = 50
#     volume_type = "gp3"
#   }
# ]

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
      iops = 3000
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

# Variable: secondary_private_ips
# Specifies secondary private IPs for the instance's primary network interface.
# Default: []
# Example: ["10.0.0.6", "10.0.0.7"]

variable "secondary_private_ips" {
  description = <<EOT
A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. 
This can only be assigned at instance creation.
EOT
  type    = list(string)
  default = []

  validation {
    condition = alltrue([
      for ip in var.secondary_private_ips : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Each secondary private IP must be a valid IPv4 address."
  }
}

# Variable: source_dest_check
# Configures source/destination checking for the instance.
# Default: true
# Example: false

variable "source_dest_check" {
  description = <<EOT
Controls if traffic is routed to the instance when the destination address does not match the instance. 
This is useful for instances acting as NATs or VPNs.
EOT
  type    = bool
  default = false

  validation {
    condition     = var.source_dest_check == true || var.source_dest_check == false
    error_message = "The source_dest_check variable must be a boolean value (true or false)."
  }
}

# Variable: subnet_id
# Specifies the subnet ID to launch the instance in.
# Default: null
# Example: "subnet-12345678"

variable "subnet_id" {
  description = "The VPC Subnet ID to launch the instance in."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for subnet in var.subnet_id : can(regex("^subnet-[a-z0-9]+$", subnet))
    ])
    error_message = "Each subnet ID must be a valid subnet ID (e.g., subnet-12345678)."
  }
}




# Variable: tags
# Assigns tags to the instance.
# Default: {}
# Example: { "Environment" = "Production", "Application" = "WebApp" }

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {
    "Environment" = "Production"
    "Application" = "WebApp"
  }

  validation {
    condition = alltrue([
      for key, value in var.tags : 
      can(regex("^[a-zA-Z0-9-_]+$", key)) && 
      can(regex("^[a-zA-Z0-9-_ ]+$", value))
    ])
    error_message = "Each tag key must only contain alphanumeric characters, hyphens, and underscores. Each tag value must only contain alphanumeric characters, hyphens, underscores, and spaces."
  }
}

# Variable: tenancy
# Configures tenancy of the instance in the VPC.
# Default: "default"
# Example: "dedicated"
# Constraints:
# - Must be null, "default", "dedicated", or "host".

variable "tenancy" {
  description = <<EOT
The tenancy of the instance (if the instance is running in a VPC). 
Available values: 'default', 'dedicated', 'host'.
EOT
  type        = string
  default     = "default"
  validation {
    condition     = var.tenancy == null || contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "The 'tenancy' must be null, 'default', 'dedicated', or 'host'."
  }
}

# Variable: user_data
# Configures user data to provide at instance launch.
# Default: null
# Example: file("user_data.sh")

variable "user_data" {
  description = <<EOT
The user data to provide when launching the instance. 
Do not pass gzip-compressed data via this argument; use `user_data_base64` instead.
EOT
  type    = string
  default = null
}

# Variable: user_data_base64
# Configures Base64-encoded user data for the instance.
# Default: null
# Example: base64encode(file("user_data.sh"))

variable "user_data_base64" {
  description = <<EOT
Base64-encoded binary user data to provide when launching the instance. 
Use this for data that is not a valid UTF-8 string, such as gzip-encoded data.
EOT
  type    = string
  default = null
}

# Variable: user_data_replace_on_change
# Triggers instance replacement on user data changes.
# Default: false
# Example: true

variable "user_data_replace_on_change" {
  description = <<EOT
If true, changes to `user_data` or `user_data_base64` will trigger a destroy and recreate of the instance. 
Defaults to false if not set.
EOT
  type    = bool
  default = false
}



# Variable: vpc_security_group_ids
# Specifies the security group IDs to associate with the instance.
# Default: []
# Example: ["sg-12345678", "sg-87654321"]

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for sg_id in var.vpc_security_group_ids : can(regex("^sg-[a-z0-9]+$", sg_id))
    ])
    error_message = "Each security group ID must be a valid security group ID (e.g., sg-12345678)."
  }
}

# Variable: timeouts
# Configures timeouts for creating, updating, and deleting EC2 instance resources.
# Default: {}
# Example: { "create" = "10m", "delete" = "5m" }

variable "timeouts" {
  description = "Timeouts for instance creation, update, and deletion"
  type = object({
    create = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {
    create = null
    update = null
    delete = null
  }
}


variable "iam_role_name" {
  description = "The name of the IAM role to attach to the instances"
  type        = string
}

variable "create_iam_role" {
  description = "Whether to create the IAM role if it doesn't exist"
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to attach to the instances"
  type        = string
}

variable "iam_role_policies" {
  description = "Policies to attach to the IAM role"
  type        = map(string)
}


variable "iam_role_tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}


##*************************************************************************##
# Primary AWS region for the provider
variable "region" {
  description = "The AWS region to be used by the primary provider. Example: us-east-1, us-west-2."
  type        = string
  default     = "ca-central-1"
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
    Project     = "example-project"
  }
}



#######################################################################################################################
#####Security Group Variables#############################################################

// VPC ID where the security group will be created
variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string

  // Validation to ensure the VPC ID is in the correct format
  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "The VPC ID must be in the format 'vpc-xxxxxxxx' or 'vpc-xxxxxxxxxxxxxxxxx'."
  }
}

// Name of the security group
variable "security_group_name" {
  description = "The name of the security group"
  type        = string

  // Validation to ensure the security group name is not empty
  validation {
    condition     = length(var.security_group_name) > 0
    error_message = "The security group name must not be empty."
  }
}

// Description of the security group
variable "security_group_description" {
  description = "The description of the security group"
  type        = string

  // Validation to ensure the security group description is not empty
  validation {
    condition     = length(var.security_group_description) > 0
    error_message = "The security group description must not be empty."
  }
}

// List of ingress rules for the security group
variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))

  // Validation to ensure at least one ingress rule is provided
  validation {
    condition     = length(var.ingress_rules) > 0
    error_message = "At least one ingress rule must be specified."
  }
}

// List of egress rules for the security group
variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))

  // Validation to ensure at least one egress rule is provided
  validation {
    condition     = length(var.egress_rules) > 0
    error_message = "At least one egress rule must be specified."
  }
}

# Security group tags to apply to all resources managed by the providers
variable "security_group_tags" {
  description = <<EOT
A map of Security group tags to be applied to all Security groups which has been created. 
Tags are key-value pairs that help with resource identification, cost management, and access control.
Examples:
- Environment: dev, test, prod
- Team: DevOps, Security
- Project: your-project-name
EOT
  type = map(string)
  default = {
    Name = "Windows Firewall"
    purpose        = "Restrict access"
    Application     = "Citrix-Test"
  }
}

###########################################################################################################################################
##Naming Convention Standards################################################





// Purpose or name of the application (e.g., "sturbom")
variable "purpose" {
  description = "Name of the Application purpose to define instance name as per naming convention Standards"
  type        = string

  // Validation to ensure the purpose is not empty
  validation {
    condition     = length(var.purpose) > 0
    error_message = "The purpose must not be empty."
  }
}

// Additional tags to apply to resources
variable "additional_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}

  // No specific validation needed as the default is an empty map
}




variable "instances" {
  description = "List of instances to create"
  type = list(object({
    ami              = string
    instance_type    = string
    key_name         = string
    additional_tags  = optional(map(string))
  }))

}




variable "os_family" {
  description = "The operating system family is to define name of the instance as per Naming convention standards(e.g., l for Linux, w for windows)"
  type        = string

  validation {
    condition     = contains(["l", "w"], var.os_family)
    error_message = "The os_family variable must be either 'linux' or 'windows'."
  }
}

/*

################################################################################
# Log Retention
################################################################################

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs for security purposes."
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days > 0
    error_message = "Log retention days must be a positive number."
  }
}

################################################################################
# Log Bucket Name
################################################################################

variable "log_bucket_name" {
  description = "Name of the S3 bucket for storing CloudTrail logs."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]{3,63}$", var.log_bucket_name))
    error_message = "Bucket name must be 3-63 characters long and can only contain letters, numbers, hyphens, and dots."
  }
}

################################################################################
# Security Log Retention
################################################################################

variable "security_log_retention_days" {
  description = "Number of days to retain security logs in CloudWatch."
  type        = number
  default     = 180
  validation {
    condition     = var.security_log_retention_days > 0
    error_message = "Security log retention days must be a positive number."
  }
}

################################################################################
# Manulife-Approved AMIs
################################################################################

variable "manulife_approved_ami_names" {
  description = "List of AMI names approved by Manulife for resource provisioning."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.manulife_approved_ami_names) > 0
    error_message = "At least one approved AMI name must be specified."
  }
}

################################################################################
# Security Group Variables
################################################################################

variable "security_group_id" {
  description = "The ID of the security group for configuring rules."
  type        = string
  validation {
    condition     = can(regex("^sg-[0-9a-f]{8,17}$", var.security_group_id))
    error_message = "Security group ID must be in the format 'sg-xxxxxxxx' or 'sg-xxxxxxxxxxxxxxxxx'."
  }
}

variable "security_rule_description" {
  description = "Description for the security group rule."
  type        = string
  default     = "Managed by Terraform"
  validation {
    condition     = length(var.security_rule_description) <= 255
    error_message = "Security group rule description must not exceed 255 characters."
  }
}

################################################################################
# Compliance Check Variables
################################################################################

variable "compliance_check_instance_ids" {
  description = "List of instance IDs for running compliance checks."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.compliance_check_instance_ids) > 0
    error_message = "At least one instance ID must be specified for compliance checks."
  }
}

################################################################################
# Threat Protection and Data Leakage Variables
################################################################################

variable "threat_agent_install_command" {
  description = "Command to install and configure the threat protection agent."
  type        = string
  default     = "sudo apt-get update && sudo apt-get install -y manulife-threat-agent"
}

variable "data_leakage_prevention_command" {
  description = "Command to install and enable the data leakage prevention agent."
  type        = string
  default     = "sudo apt-get update && sudo apt-get install -y manulife-dlp-agent"
}

################################################################################
# NTP Servers
################################################################################

variable "ntp_servers" {
  description = "List of NTP servers for time synchronization."
  type        = list(string)
  default     = ["ntp1.manulife.com", "ntp2.manulife.com"]
}

################################################################################
# Vulnerability Scanning Variables
################################################################################

variable "vulnerability_scanning_command" {
  description = "Command to install and schedule vulnerability scanning."
  type        = string
  default     = "sudo apt-get update && sudo apt-get install -y manulife-vulnerability-agent"
}

################################################################################
# Approved Resource Owner IDs
################################################################################

variable "approved_resource_owners" {
  description = "List of approved AWS account IDs for resource provisioning."
  type        = list(string)
  default     = ["123456789012"]
  validation {
    condition     = alltrue([for id in var.approved_resource_owners : can(regex("^[0-9]{12}$", id))])
    error_message = "All approved resource owner IDs must be 12-digit numbers."
  }
}
################################################################################
# Centralized Security Logs Bucket Name
################################################################################

variable "security_logs_bucket_name" {
  description = "Name of the S3 bucket for centralized security logs."
  type        = string
  default     = "manulife-security-logs"
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]{3,63}$", var.security_logs_bucket_name))
    error_message = "Bucket name must be 3-63 characters long and can only contain letters, numbers, hyphens, and dots."
  }
}

################################################################################
# Default Tags
################################################################################



################################################################################
# Additional Variables
################################################################################

*/








