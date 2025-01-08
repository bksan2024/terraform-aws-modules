

# Variable: maintenance_options
# Specifies the maintenance options for the instance.
# Default: { "auto_recovery" = "enabled" }
# Example: { "auto_recovery" = "enabled" }

variable "maintenance_options" {
  description = <<EOT
Defines the maintenance options for the instance.
Specify settings such as auto-recovery or custom maintenance windows.
EOT
  type        = map(any)
  default     = { "auto_recovery" = "disabled" }
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
  type        = bool
  default     = false
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
    delete_on_termination = optional(bool, true)    # Optional
    device_name           = string  # Required
    encrypted             = optional(bool, false)    # Optional
    iops                  = optional(number, 0)  # Optional
    kms_key_id            = optional(string, "")  # Optional
    snapshot_id           = optional(string, "")  # Optional
    volume_size           = number  # Required
    volume_type           = optional(string, "gp2")  # Optional
    throughput            = optional(number, 0)  # Optional
    tags                  = optional(map(string), {})  # Optional
  }))
  #default = []

  validation {
    condition     = alltrue([for device in var.ebs_block_device : device.device_name != ""])
    error_message = "Each EBS block device must have a device name."
  }

  validation {
    condition     = alltrue([for device in var.ebs_block_device : device.volume_size > 0])
    error_message = "Each EBS block device must have a volume size greater than 0."
  }

  validation {
    condition     = alltrue([for device in var.ebs_block_device : device.iops >= 0])
    error_message = "IOPS must be a non-negative number."
  }

  validation {
    condition     = alltrue([for device in var.ebs_block_device : device.throughput >= 0])
    error_message = "Throughput must be a non-negative number."
  }

  validation {
    condition     = alltrue([for device in var.ebs_block_device : device.volume_type != ""])
    error_message = "Each EBS block device must have a volume type."
  }
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
  type        = bool
  default     = true

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
  type        = bool
  default     = false

  validation {
    condition     = var.enclave_options_enabled == true || var.enclave_options_enabled == false
    error_message = "The enclave_options_enabled variable must be a boolean value (true or false)."
  }
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
  type        = bool
  default     = false
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
  type        = string
  default     = null
}

# Variable: iam_instance_profile
# Specifies the IAM Instance Profile to use.
# Default: null
# Example: "my-instance-profile"

#tflint-ignore: all
variable "iam_instance_profile" {
  description = <<EOT
IAM Instance Profile to launch the instance with.
This is specified as the name of the Instance Profile.
EOT
  type        = string
  default     = null
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
  type        = string
  default     = "stop"
  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "The 'instance_initiated_shutdown_behavior' must be 'stop' or 'terminate'."
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
  type = list(object({
    id      = optional(string, null)   # Optional Launch Template ID
    name    = optional(string, null)   # Optional Launch Template name
    version = optional(string, null)   # Optional Launch Template version
  }))
}
# Variable: metadata_options
# Specifies the metadata options to be applied dynamically to the instances in the launch template.


variable "metadata_options" {
  description = "Specifies the metadata options EC2 instance with IMDSv2."
  type        = map(string)
  default = {
    http_endpoint               = "enabled"  # Enables metadata service
    http_tokens                 = "required" # Enforces IMDSv2
    http_put_response_hop_limit = "1"        # Restricts metadata response hops to 1
    http_protocol_ipv6          = "disabled" # Disables IPv6 metadata requests
    instance_metadata_tags      = "disabled" # Disables metadata tags
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
  default     = {}
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
  type = object({
    hostname_type                     = string
    enable_resource_name_dns_a_record = bool
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

# Variable: secondary_private_ips
# Specifies secondary private IPs for the instance's primary network interface.
# Default: []
# Example: ["10.0.0.6", "10.0.0.7"]

variable "secondary_private_ips" {
  description = <<EOT
A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. 
This can only be assigned at instance creation.
EOT
  type        = list(string)
  default     = []

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
  type        = bool
  default     = false

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
  default = {
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
  type        = string
  default     = null
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
  type        = string
  default     = null
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
  type        = bool
  default     = false
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



variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to attach to the instances"
  type        = string
  default     = null
}



##*************************************************************************##
# Primary AWS region for the provider
#tflint-ignore: all
variable "region" {
  description = "The AWS region to be used by the primary provider. Example: us-east-1, us-west-2."
  type        = string
  default     = "ca-central-1"
  validation {
    condition     = contains(["ca-central-1", "us-east-1", "us-west-1", "us-east-2", "us-west-2"], var.region)
    error_message = "The name of the region must be from the variable region."
  }
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
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "DevOps"
    Project     = "example-project"
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
  description = "Map of instances to create"
  type = list(object({
    ami             = optional(string, null) # Optional AMI with default value null
    instance_type   = optional(string, null) # Optional instance type with default value null
    key_name        = optional(string, null) # Optional key name with default value null
    additional_tags = optional(map(string), {}) # Optional additional tags with default value empty map
  }))

  validation {
    condition     = length(var.launch_template) == 0 || alltrue([for instance in var.instances : instance.ami != null])
    error_message = "Each instance must have an AMI specified if no launch template is provided."
  }

  validation {
    condition     = length(var.launch_template) == 0 || alltrue([for instance in var.instances : instance.instance_type != null])
    error_message = "Each instance must have an instance type specified if no launch template is provided."
  }
}



variable "os_family" {
  description = "The operating system family is to define name of the instance as per Naming convention standards(e.g., l for Linux, w for windows)"
  type        = string

  validation {
    condition     = contains(["l", "w"], var.os_family)
    error_message = "The os_family variable must be either 'linux' or 'windows'."
  }
}
variable "cost_center" {
  description = "The cost center associated with the resources. Must be a 4-digit number."
  type        = number
  default     = 1234
  validation {
    condition     = var.cost_center == null || can(regex("^\\d{4}$", var.cost_center))
    error_message = "The cost_center must be a 4-digit number. Additional info: https://manulife-ets.atlassian.net/wiki/spaces/CPA/pages/13643055273/Cost+Center"
  }
}

variable "environment" {
  description = "The environment that the primary resources are provisioned for."
  type        = string
  default     = "prod"
  validation {
    condition     = var.environment == null || can(regex("^(?i)(dev|test|uat|sandbox|nonprod|prod|dr)$", var.environment))
    error_message = "The environment must be one of; dev, test, uat, sandbox, nonprod, prod, dr (case insensitive)."
  }
}


variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.vpc_security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
}

