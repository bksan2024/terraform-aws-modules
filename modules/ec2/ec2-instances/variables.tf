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

# Variable: ami
# Specifies the AMI ID to use for the instance.
# Default: null
# Example: "ami-0c55b159cbfafe1f0"
# Constraints:
# - Must either be null or a valid AMI ID starting with "ami-".

variable "ami" {
  description = "AMI ID to use for the instance.'."
  type        = string
  default     = null
  validation {
    condition     = var.ami == null || can(regex("^ami-[a-z0-9]+$", var.ami))
    error_message = "The 'ami' must either be null or a valid AMI ID starting with 'ami-'."
  }
}



# Variable: associate_public_ip_address
# Indicates whether to associate a public IP address with the instance.
# Default: false
# Example: true

variable "associate_public_ip_address" {
  description = <<EOT
Indicates whether to associate a public IP address with the instance.
Set to 'true' for instances in public subnets, or 'false' for private subnets.
Defaults to 'false', ensuring instances remain private unless explicitly set.
EOT
  type    = bool
  default = false

  validation {
    condition     = var.associate_public_ip_address == false
    error_message = "The associate_public_ip_address variable must be set to false."
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
  description = "Specifies the Availability Zone (AZ) to start the instance in. Defaults to 'ca-central-1a' for instances in Canada Central."
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
    tags                  = optional(map(string))
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

# Variable: ebs_optimized
# Specifies if the EC2 instance should be EBS-optimized.
# Default: false
# Example: true

variable "ebs_optimized" {
  description = <<EOT
If true, the launched EC2 instance will be EBS-optimized, providing dedicated throughput for EBS volumes.
Not all instance types support this feature.
Defaults to 'false' to ensure compatibility with all instance types.
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

# Variable: hibernation
# Determines whether the instance supports hibernation.
# Default: false
# Example: false

variable "hibernation" {
  description = <<EOT
If true, the launched EC2 instance will support hibernation.
Ensure the instance type and AMI support this feature.
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
  description = "The type of the EC2 instance to launch in the Auto Scaling Group. Cannot be used with `instance_requirements`."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium", "m5.large", "m5.2xlarge", "c5.2xlarge"], var.instance_type)
    error_message = "The instance type must be one of the following: t2.micro, t2.small, t2.medium, m5.large, m5.xlarge."
  }
}

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

# Variable: ipv6_address_count
# Specifies the number of IPv6 addresses to associate with the primary network interface.
# Default: 0
# Example: 1
# Constraints:
# - Must be a non-negative number.

variable "ipv6_address_count" {
  description = <<EOT
The number of IPv6 addresses to associate with the primary network interface.
Amazon EC2 automatically assigns the addresses from the subnet range.
EOT
  type    = number
  default = 0
  validation {
    condition     = var.ipv6_address_count >= 0
    error_message = "The 'ipv6_address_count' must be a non-negative number."
  }
}

# Variable: ipv6_addresses
# Specifies one or more IPv6 addresses for the primary network interface.
# Default: []
# Example: ["2600:1f16:abcd::1"]

variable "ipv6_addresses" {
  description = <<EOT
Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface.
EOT
  type    = list(any)
  default = []
}

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
  description = "Specifies the metadata options for dynamic configuration in the launch template."
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
  description = "If true, the launched EC2 instance will have detailed monitoring enabled."
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
  description = "Configuration for network interfaces"
  type = map(object({
    device_index          = number
    network_interface_id  = optional(string)
    delete_on_termination = optional(bool)
    additional_tags       = optional(map(string), {})
  }))
}

###
###
variable "nic_tags" {
  description = "Tags to apply to network interfaces"
  type        = map(string)
  default     = {}
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


# Variable: root_block_device_encrypted
# Specifies whether the root block device is encrypted.
# Default: true
# Example: true

variable "root_block_device_encrypted" {
  description = "Whether the root block device is encrypted."
  type        = bool
  default     = true

  validation {
    condition     = var.root_block_device_encrypted == true || var.root_block_device_encrypted == false
    error_message = "The root_block_device_encrypted variable must be a boolean value (true or false)."
  }
}

# Variable: root_block_device_volume_type
# Specifies the volume type of the root block device.
# Default: "gp3"
# Example: "io1"

variable "root_block_device_volume_type" {
  description = "The volume type of the root block device."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], var.root_block_device_volume_type)
    error_message = "The root_block_device_volume_type must be one of: gp2, gp3, io1, io2, sc1, st1, standard."
  }
}

# Variable: root_block_device_throughput
# Specifies the throughput for the root block device.
# Default: 125
# Example: 200

variable "root_block_device_throughput" {
  description = "The throughput for the root block device."
  type        = number
  default     = 125

  validation {
    condition     = var.root_block_device_throughput > 0
    error_message = "The root_block_device_throughput must be a positive number."
  }
}

# Variable: root_block_device_volume_size
# Specifies the size of the root block device in GB.
# Default: 50
# Example: 100

variable "root_block_device_volume_size" {
  description = "The size of the root block device."
  type        = number
  default     = 50

  validation {
    condition     = var.root_block_device_volume_size > 0
    error_message = "The root_block_device_volume_size must be a positive number."
  }
}

# Variable: root_block_device_tags
# Specifies tags to apply to the root block device.
# Default: {}
# Example: { "Name" = "root-volume" }

variable "root_block_device_tags" {
  description = "Tags to apply to the root block device."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.root_block_device_tags : 
      can(regex("^[a-zA-Z0-9-_]+$", key)) && 
      can(regex("^[a-zA-Z0-9-_ ]+$", value))
    ])
    error_message = "Each tag key must only contain alphanumeric characters, hyphens, and underscores. Each tag value must only contain alphanumeric characters, hyphens, underscores, and spaces."
  }
}

# Variable: ebs_block_device_device_name
# Specifies the device name for the EBS block device.
# Default: "/dev/xvdf"
# Example: "/dev/sdf"

variable "ebs_block_device_device_name" {
  description = "The device name for the EBS block device."
  type        = string
  default     = "/dev/xvdf"

  validation {
    condition     = can(regex("^/dev/xvd[b-z]$", var.ebs_block_device_device_name))
    error_message = "The ebs_block_device_device_name must be a valid device name (e.g., /dev/xvdf)."
  }
}

# Variable: ebs_block_device_volume_type
# Specifies the volume type for the EBS block device.
# Default: "gp3"
# Example: "io1"

variable "ebs_block_device_volume_type" {
  description = "The volume type of the EBS block device."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], var.ebs_block_device_volume_type)
    error_message = "The ebs_block_device_volume_type must be one of: gp2, gp3, io1, io2, sc1, st1, standard."
  }
}

# Variable: ebs_block_device_volume_size
# Specifies the size of the EBS block device in GB.
# Default: 10
# Example: 20
variable "ebs_block_device_volume_size" {
  description = "The size of the EBS block device."
  type        = number
  default     = 10

  validation {
    condition     = var.ebs_block_device_volume_size > 0
    error_message = "The ebs_block_device_volume_size must be a positive number."
  }
}
# Variable: ebs_block_device_throughput
# Specifies the throughput for the EBS block device in MiB/s.
# Default: 125
# Example: 200

variable "ebs_block_device_throughput" {
  description = "The throughput for the EBS block device."
  type        = number
  default     = 125

  validation {
    condition     = var.ebs_block_device_throughput > 0
    error_message = "The ebs_block_device_throughput must be a positive number."
  }
}

# Variable: ebs_block_device_encrypted
# Specifies whether the EBS block device is encrypted.
# Default: true
# Example: true

variable "ebs_block_device_encrypted" {
  description = "Whether the EBS block device is encrypted."
  type        = bool
  default     = true

  validation {
    condition     = var.ebs_block_device_encrypted == true || var.ebs_block_device_encrypted == false
    error_message = "The ebs_block_device_encrypted variable must be a boolean value (true or false)."
  }
}

# Variable: ebs_block_device_kms_key_id
# Specifies the KMS key ID for the EBS block device encryption.
# Default: ""
# Example: "arn:aws:kms:region:account-id:key/key-id"
variable "ebs_block_device_kms_key_id" {
  description = "The KMS key ID for the EBS block device."
  type        = string
  default     = ""

  validation {
    condition     = var.ebs_block_device_kms_key_id == "" || can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.ebs_block_device_kms_key_id))
    error_message = "The ebs_block_device_kms_key_id must be a valid KMS key ARN or an empty string."
  }
}
# Variable: ebs_block_device_tags
# Specifies tags to apply to the EBS block device.
# Default: {}
# Example: { "MountPoint" = "/mnt/data" }

variable "ebs_block_device_tags" {
  description = "Tags to apply to the EBS block device."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.ebs_block_device_tags : 
      can(regex("^[a-zA-Z0-9-_]+$", key)) && 
      can(regex("^[a-zA-Z0-9-_ ]+$", value))
    ])
    error_message = "Each tag key must only contain alphanumeric characters, hyphens, and underscores. Each tag value must only contain alphanumeric characters, hyphens, underscores, and spaces."
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
  description = <<EOT
Define maximum timeout for creating, updating, and deleting EC2 instance resources. 
Use keys 'create', 'update', and 'delete' for specifying timeouts in seconds.
EOT
  type    = map(string)
  default = {}

  validation {
    condition = alltrue([
      for key, value in var.timeouts : 
      contains(["create", "update", "delete"], key) &&
      can(regex("^[0-9]+[smhd]$", value))
    ])
    error_message = "Each timeout key must be one of 'create', 'update', or 'delete', and each value must be a valid duration (e.g., '10m' for 10 minutes, '5m' for 5 minutes)."
  }
}

# Variable: create_iam_instance_profile
# Determines whether to create an IAM instance profile.
# Default: false
# Example: true

variable "create_iam_instance_profile" {
  description = <<EOT
Determines whether an IAM instance profile should be created.
- Set to `true` to create a new IAM instance profile along with a new IAM role.
- Set to `false` to use an existing IAM instance profile.
EOT
  type    = bool
  default = false

  validation {
    condition     = var.create_iam_instance_profile == true || var.create_iam_instance_profile == false
    error_message = "The create_iam_instance_profile variable must be a boolean value (true or false)."
  }
}

# Variable: iam_role_name
# Specifies the name of the IAM role to create.
# Default: null
# Example: "my-ec2-role"
# Constraints:
# - Must be null or a string with a maximum length of 128 characters.

variable "iam_role_name" {
  description = <<EOT
Specifies the name to use for the IAM role created. 
If not provided, the `name` variable will be used as the default.
EOT
  type    = string
  default = "my-ec2-role"
}

# Variable: iam_role_use_name_prefix
# Determines whether to use the specified IAM role name as a prefix.
# Default: true
# Example: false

variable "iam_role_use_name_prefix" {
  description = <<EOT
Determines whether the specified IAM role name (`iam_role_name` or `name`) should be used as a prefix.
- Set to `true` to append a random string for uniqueness.
- Set to `false` to use the provided name as-is.
EOT
  type    = bool
  default = false

}

# Variable: iam_role_path
# Configures the path for the IAM role.
# Default: null
# Example: "/service-role/"
# Constraints:
# - Must be null or a valid IAM path.

variable "iam_role_path" {
  description = "Specifies the path for the IAM role. This is useful for organizing IAM resources."
  type        = string
  default     = null
  validation {
    condition     = var.iam_role_path == null || can(regex("^/[a-zA-Z0-9_/]*$", var.iam_role_path))
    error_message = "The 'iam_role_path' must be null or a valid IAM path starting and ending with a forward slash."
  }
}

# Variable: iam_role_description
# Provides a description for the IAM role.
# Default: null
# Example: "Role for EC2 instances to access S3 buckets."
# Constraints:
# - Must be null or a string with a maximum length of 256 characters.

variable "iam_role_description" {
  description = "Provides a description for the IAM role."
  type        = string
  default     = null

}
# Variable: iam_role_permissions_boundary
# Configures the permissions boundary for the IAM role.
# Default: null
# Example: "arn:aws:iam::123456789012:policy/permissions-boundary"
# Constraints:
# - Must be null or a valid IAM policy ARN.

variable "iam_role_permissions_boundary" {
  description = <<EOT
Specifies the ARN of the permissions boundary policy for the IAM role. 
A permissions boundary controls the maximum permissions the role can have.
EOT
  type    = string
  default = null
}

# Variable: iam_role_policies
# Maps policies to attach to the IAM role.
# Default: {}
# Example: {
#   "S3FullAccess" = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#   "EC2FullAccess" = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
# }

variable "iam_role_policies" {
  description = <<EOT
A map of policies to attach to the IAM role.
Each policy should be specified with its name as the key and its ARN as the value.
EOT
  type    = map(string)
  default = {}
}

# Variable: iam_role_tags
# Adds additional tags to the IAM role and instance profile.
# Default: {}
# Example: { "Environment" = "Production", "Owner" = "DevOpsTeam" }

variable "iam_role_tags" {
  description = "A map of additional tags to assign to the IAM role and instance profile created."
  type        = map(string)
  default     = {}
}


# Variable: create_eip
# Determines whether a public Elastic IP (EIP) will be created and associated with the instance.
# Default: false
# Example: true

variable "create_eip" {
  description = <<EOT
Determines whether a public Elastic IP (EIP) will be created and associated with the instance. 
- Set to `true` to create and attach an EIP.
- Set to `false` to skip creating an EIP.
EOT
  type    = bool
  default = false
}

# Variable: eip_domain
# Specifies the domain in which the EIP will be used.
# Default: "vpc"
# Example: "vpc"
# Constraints:
# - Must be "vpc".

variable "eip_domain" {
  description = <<EOT
Specifies the domain in which the EIP will be used. 
For Elastic IPs associated with a VPC, this should be set to `vpc`.
EOT
  type    = string
  default = "vpc"
  validation {
    condition     = var.eip_domain == "vpc"
    error_message = "The 'eip_domain' must be set to 'vpc' as it is the only supported value for VPC-based EIPs."
  }
}

# Variable: eip_tags
# Specifies additional tags to assign to the Elastic IP (EIP).
# Default: {}
# Example: { "Environment" = "Production", "Owner" = "NetworkingTeam" }

variable "eip_tags" {
  description = <<EOT
A map of additional tags to assign to the Elastic IP (EIP). 
These tags can be used for resource management and organization.
EOT
  type    = map(string)
  default = {}
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

// Name of the cloud provider (e.g., "aws")
variable "provider_name" {
  description = "Name of the provider"
  type        = string

  // Validation to ensure the provider name is not empty
  validation {
    condition     = length(var.provider_name) > 0
    error_message = "The provider name must not be empty."
  }
}






// Name of the environment (e.g., "prod", "dev")
variable "environment_name" {
  description = "Name of the environment"
  type        = string

  // Validation to ensure the environment name is either "prod" or "dev"
  validation {
    condition     = var.environment_name == "p" || var.environment_name == "d"
    error_message = "The environment name must be either 'p' or 'd'."
  }
}

// Purpose or name of the application (e.g., "webserver")
variable "purpose" {
  description = "Name of the application"
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

// Map of instances to create
variable "instances" {
  description = "Map of instances to create"
  type = map(object({
    ami              = string
    instance_type    = string
    key_name         = string
    additional_tags  = optional(map(string))
  }))

  // Validation to ensure at least one instance is defined
  validation {
    condition     = length(var.instances) > 0
    error_message = "At least one instance must be specified."
  }
}

// Type of server to create (e.g., "web", "db")
variable "server_type" {
  description = "Type of server to create"
  type        = string
  default     = "ap"

  // Validation to ensure the server type is not empty
  validation {
    condition     = length(var.server_type) > 0
    error_message = "The server type must not be empty."
  }
}

variable "os_family" {
  description = "The operating system family (e.g., linux, windows)"
  type        = string

  validation {
    condition     = contains(["l", "w"], var.os_family)
    error_message = "The os_family variable must be either 'linux' or 'windows'."
  }
}

/*
variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch Log Group"
  type        = number
  default     = 90
}


variable "enable_guardduty" {
  description = "Enable GuardDuty detector"
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = "Enable SecurityHub best practices"
  type        = bool
  default     = true
}

variable "ssm_logging_document_content" {
  description = "Content of the SSM document for enabling instance logging"
  type        = string

  validation {
    condition     = can(jsondecode(var.ssm_logging_document_content))
    error_message = "The ssm_logging_document_content variable must be a valid JSON string."
  }
}
*/
