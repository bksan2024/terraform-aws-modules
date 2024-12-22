# Variable: name
# Specifies the name to be used for the EC2 instance.
# Default: "default-ec2-instance"
# Example: "my-ec2-instance"
# Constraints:
# - Must not exceed 256 characters.

variable "name" {
  description = "Name to be used for the EC2 instance. This will be added as a 'Name' tag for identification."
  type        = string
  default     = "default-ec2-instance"
  validation {
    condition     = length(var.name) <= 256
    error_message = "The 'name' must not exceed 256 characters."
  }
}

# Variable: ami_ssm_parameter
# Specifies the SSM parameter name for the AMI ID.
# Default: "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
# Example: "/aws/service/ami-amazon-linux-latest/ubuntu-ami"

variable "ami_ssm_parameter" {
  description = <<EOT
SSM parameter name for the AMI ID. This parameter references the AMI stored in the AWS Systems Manager Parameter Store.
Refer to AWS documentation for commonly used parameters, such as Amazon Linux AMI SSM parameters.
EOT
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
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

# Variable: ignore_ami_changes
# Determines whether Terraform should ignore changes to the AMI ID.
# Default: false
# Example: true

variable "ignore_ami_changes" {
  description = <<EOT
Determines whether Terraform should ignore changes to the AMI ID.
Changing this value will trigger instance replacement if set to true.
EOT
  type    = bool
  default = false
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


# Variable: capacity_reservation_specification
# Specifies Capacity Reservation targeting options.
# Default: {}
# Example: { "capacity_reservation_preference" = "open" }

variable "capacity_reservation_specification" {
  description = <<EOT
Describes an instance's Capacity Reservation targeting options.
Useful for specifying Capacity Reservations for predictable availability.
EOT
  type    = map(any)
  default = { "capacity_reservation_preference" = "open" }
}

# Variable: cpu_credits
# Specifies the credit option for CPU usage.
# Default: "standard"
# Example: "unlimited"
# Constraints:
# - Must be null, "unlimited", or "standard".

variable "cpu_credits" {
  description = <<EOT
Credit option for CPU usage. 
- Use 'unlimited' for burstable instances without performance limits.
- Use 'standard' for controlled burstable performance.
EOT
  type        = string
  default     = "standard"
  validation {
    condition     = var.cpu_credits == null || var.cpu_credits == "unlimited" || var.cpu_credits == "standard"
    error_message = "The 'cpu_credits' must be null, 'unlimited', or 'standard'."
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
  description = <<EOT
Additional EBS block devices to attach to the instance. 
Each block device can be customized with properties like volume type, size, and IOPS.
EOT
  type    = list(any)
  default = []
}

# Variable: ebs_optimized
# Specifies if the EC2 instance should be EBS-optimized.
# Default: true
# Example: true

variable "ebs_optimized" {
  description = <<EOT
If true, the launched EC2 instance will be EBS-optimized, providing dedicated throughput for EBS volumes.
Not all instance types support this feature.
Defaults to 'true' to ensure optimal performance for supported instances.
EOT
  type    = bool
  default = true
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
  type    = list(map(string))
  default = []
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
  description = "The type of instance to start. Refer to AWS documentation for supported instance types."
  type        = string
  default     = "t3.micro"
}

# Variable: instance_tags
# Specifies additional tags for the instance.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "DevOps" }

variable "instance_tags" {
  description = "Additional tags for the instance. These tags are merged with default tags."
  type        = map(string)
  default     = {}
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
  type    = map(string)
  default = {}
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

# Variable: private_dns_name_options
# Configures private DNS name options for the instance.
# Default: {}
# Example: { hostname_type = "ip-name", enable_resource_name_dns_a_record = true }

variable "private_dns_name_options" {
  description = "Customize the private DNS name options of the instance."
  type        = map(string)
  default     = {}
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
  type    = list(any)
  default = []
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
  default = true
}

# Variable: subnet_id
# Specifies the subnet ID to launch the instance in.
# Default: null
# Example: "subnet-12345678"

variable "subnet_id" {
  description = "The VPC Subnet ID to launch the instance in."
  type        = list(string)
  default     = null
}

# Variable: tags
# Assigns tags to the instance.
# Default: {}
# Example: { "Environment" = "Production", "Application" = "WebApp" }

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
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


# Variable: volume_tags
# Specifies tags to assign to volumes created by the instance at launch time.
# Default: {}
# Example: { "Environment" = "Production", "Team" = "Storage" }

variable "volume_tags" {
  description = "A mapping of tags to assign to the volumes created by the instance at launch time."
  type        = map(string)
  default     = {}
}

# Variable: enable_volume_tags
# Determines whether to enable tags for all volumes created with the instance.
# Default: true
# Example: true

variable "enable_volume_tags" {
  description = <<EOT
Whether to enable volume tags for all volumes created with the instance. 
If enabled, it may conflict with `root_block_device` tags.
EOT
  type    = bool
  default = true
}

# Variable: vpc_security_group_ids
# Specifies the security group IDs to associate with the instance.
# Default: []
# Example: ["sg-12345678", "sg-87654321"]

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = []
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
}

# Variable: cpu_options
# Specifies CPU options to apply at instance launch.
# Default: {}
# Example: { core_count = 4, threads_per_core = 2 }

variable "cpu_options" {
  description = "Defines CPU options to apply to the instance at launch time."
  type        = any
  default     = {}
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
  default = 2 
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
  default = 1 
  validation {
    condition     = var.cpu_threads_per_core == null || var.cpu_threads_per_core > 0
    error_message = "The 'cpu_threads_per_core' must be null or a positive integer."
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
  validation {
    condition     = var.iam_role_name == null || length(var.iam_role_name) <= 128
    error_message = "The 'iam_role_name' must be null or a string with a maximum length of 128 characters."
  }
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
  default = true
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
  validation {
    condition     = var.iam_role_description == null || length(var.iam_role_description) <= 256
    error_message = "The 'iam_role_description' must be null or a string with a maximum length of 256 characters."
  }
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
  validation {
    condition     = var.iam_role_permissions_boundary == null || can(regex("^arn:aws:iam::[0-9]{12}:policy/[a-zA-Z0-9-_/.]+$", var.iam_role_permissions_boundary))
    error_message = "The 'iam_role_permissions_boundary' must be null or a valid IAM policy ARN."
  }
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
    Project     = "example-project"
  }
}

