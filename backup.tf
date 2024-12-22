variable "create" {
  description = "Whether to create an instance. Set to 'true' to create resources or 'false' to skip resource creation."
  type        = bool
  default     = true
  # This variable acts as a global toggle to control resource creation.
  # Example: true
}

variable "name" {
  description = "Name to be used for the EC2 instance. This will be added as a 'Name' tag for identification."
  type        = string
  default     = ""
  validation {
    condition     = length(var.name) <= 256
    error_message = "The 'name' must not exceed 256 characters."
  }
  # The 'name' tag is a common convention for easy identification of AWS resources.
  # Ensure the name is meaningful for organizational purposes.
  # Example: "my-ec2-instance"
}

variable "ami_ssm_parameter" {
  description = <<EOT
SSM parameter name for the AMI ID. This parameter references the AMI stored in the AWS Systems Manager Parameter Store.
Refer to AWS documentation for commonly used parameters, such as Amazon Linux AMI SSM parameters.
EOT
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  # This variable is used when 'ami' is not explicitly provided.
  # Useful for dynamically fetching AMI IDs from Parameter Store.
  # Example: "/aws/service/ami-amazon-linux-latest/ubuntu-ami"
}

variable "ami" {
  description = "AMI ID to use for the instance. If not provided, it defaults to null and uses the SSM parameter defined in 'ami_ssm_parameter'."
  type        = string
  default     = null
  validation {
    condition     = var.ami == null || can(regex("^ami-[a-z0-9]+$", var.ami))
    error_message = "The 'ami' must either be null or a valid AMI ID starting with 'ami-'."
  }
  # Direct AMI ID overrides any AMI fetched via 'ami_ssm_parameter'.
  # Ensure the AMI ID is valid and exists in the target AWS region.
  # Example: "ami-0c55b159cbfafe1f0"
}

variable "ignore_ami_changes" {
  description = <<EOT
Determines whether Terraform should ignore changes to the AMI ID.
Changing this value will trigger instance replacement if set to true.
EOT
  type    = bool
  default = false
  # Set to `true` when AMI updates should not trigger instance replacement.
  # Common for environments requiring immutability of instances.
  # Example: true
}

variable "associate_public_ip_address" {
  description = <<EOT
Indicates whether to associate a public IP address with the instance.
Set to 'true' for instances in public subnets, or 'false' for private subnets.
Defaults to 'null', allowing AWS to decide.
EOT
  type    = bool
  default = null
  # Typically set to `true` for instances requiring internet access in a public subnet.
  # For private subnets, this is usually `false` or `null`.
  # Example: true
}

variable "maintenance_options" {
  description = <<EOT
Defines the maintenance options for the instance.
Specify settings such as auto-recovery or custom maintenance windows.
EOT
  type    = map(any)
  default = {}
  # Configures EC2 instance behavior during maintenance events.
  # Example: { "auto_recovery" = "enabled" }
}

variable "availability_zone" {
  description = "Specifies the Availability Zone (AZ) to start the instance in. Defaults to 'null' for AWS automatic selection."
  type        = string
  default     = null
  # Specify the AZ for better control over resource distribution.
  # Example: "us-east-1a"
}

variable "capacity_reservation_specification" {
  description = <<EOT
Describes an instance's Capacity Reservation targeting options.
Useful for specifying Capacity Reservations for predictable availability.
EOT
  type    = map(any)
  default = {}
  # Use this variable to configure reserved capacity for EC2 instances.
  # Example: { "capacity_reservation_preference" = "open" }
}

variable "cpu_credits" {
  description = <<EOT
Credit option for CPU usage. 
- Use 'unlimited' for burstable instances without performance limits.
- Use 'standard' for controlled burstable performance.
EOT
  type        = string
  default     = null
  validation {
    condition     = var.cpu_credits == null || var.cpu_credits == "unlimited" || var.cpu_credits == "standard"
    error_message = "The 'cpu_credits' must be null, 'unlimited', or 'standard'."
  }
  # Configure this for T2/T3 instance types to control bursting behavior.
  # Example: "unlimited"
}

variable "disable_api_termination" {
  description = <<EOT
If true, enables EC2 Instance Termination Protection. This prevents accidental termination of the instance.
EOT
  type    = bool
  default = null
  # This should be `true` for critical instances that should not be accidentally terminated.
  # Example: true
}

variable "ebs_block_device" {
  description = <<EOT
Additional EBS block devices to attach to the instance. 
Each block device can be customized with properties like volume type, size, and IOPS.
EOT
  type    = list(any)
  default = []
  # Use this for attaching additional storage to the instance.
  # Example: [
  #   { device_name = "/dev/xvdb", volume_type = "gp2", volume_size = 100 }
  # ]
}

variable "ebs_optimized" {
  description = <<EOT
If true, the launched EC2 instance will be EBS-optimized, providing dedicated throughput for EBS volumes.
Not all instance types support this feature.
EOT
  type    = bool
  default = null
  # Recommended for workloads requiring high I/O performance for EBS volumes.
  # Example: true
}

variable "enclave_options_enabled" {
  description = <<EOT
Whether Nitro Enclaves will be enabled on the instance.
Nitro Enclaves provide an isolated environment for sensitive data processing.
Defaults to false.
EOT
  type    = bool
  default = null
  # Enable this for instances requiring secure, isolated data processing environments.
  # Example: false
}

variable "ephemeral_block_device" {
  description = <<EOT
Customize ephemeral (also known as instance store) volumes on the instance.
These are temporary storage devices available for certain instance types.
EOT
  type    = list(map(string))
  default = []
  # Use for workloads requiring temporary, high-speed storage.
  # Data stored in these devices is lost upon instance stop/termination.
  # Example: [
  #   { device_name = "/dev/xvdc", virtual_name = "ephemeral0" }
  # ]
}

variable "get_password_data" {
  description = <<EOT
If true, wait for password data to become available and retrieve it.
This is typically used for Windows instances to retrieve the administrator password.
EOT
  type    = bool
  default = null
  # Enable only for Windows instances when retrieving admin credentials is necessary.
  # Example: true
}

variable "hibernation" {
  description = <<EOT
If true, the launched EC2 instance will support hibernation.
Ensure the instance type and AMI support this feature.
EOT
  type    = bool
  default = null
  # Useful for long-running workloads that need to pause and resume later.
  # Hibernation requires an encrypted root EBS volume.
  # Example: true
}

variable "host_id" {
  description = <<EOT
ID of a dedicated host that the instance will be assigned to.
This is used for launching an instance on a specific dedicated host.
EOT
  type    = string
  default = null
  # Specify this only if using a dedicated host setup for instance tenancy.
  # Example: "host-12345678"
}

variable "iam_instance_profile" {
  description = <<EOT
IAM Instance Profile to launch the instance with.
This is specified as the name of the Instance Profile.
EOT
  type    = string
  default = null
  # Use this for instances needing specific IAM permissions.
  # This value is ignored if `create_iam_instance_profile` is set to `true`.
  # Example: "my-instance-profile"
}

variable "instance_initiated_shutdown_behavior" {
  description = <<EOT
Shutdown behavior for the instance.
Defaults to 'stop' for EBS-backed instances and 'terminate' for instance-store instances.
Cannot be set on instance-store instances.
EOT
  type    = string
  default = null
  validation {
    condition     = var.instance_initiated_shutdown_behavior == null || contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "The 'instance_initiated_shutdown_behavior' must be null, 'stop', or 'terminate'."
  }
  # Use 'stop' for environments needing to retain instance state after shutdown.
  # Example: "stop"
}

variable "instance_type" {
  description = "The type of instance to start. Refer to AWS documentation for supported instance types."
  type        = string
  default     = "t3.micro"
  # Critical variable determining performance and cost. Match to workload needs.
  # Example: "m5.large"
}

variable "instance_tags" {
  description = "Additional tags for the instance. These tags are merged with default tags."
  type        = map(string)
  default     = {}
  # Tags help organize and identify resources. Include key-value pairs relevant to your organization.
  # Example: { "Environment" = "Production", "Team" = "DevOps" }
}

variable "ipv6_address_count" {
  description = <<EOT
The number of IPv6 addresses to associate with the primary network interface.
Amazon EC2 automatically assigns the addresses from the subnet range.
EOT
  type    = number
  default = null
  validation {
    condition     = var.ipv6_address_count == null || var.ipv6_address_count >= 0
    error_message = "The 'ipv6_address_count' must be null or a non-negative number."
  }
  # Use for environments with IPv6 networking. Ensure your subnet supports IPv6.
  # Example: 1
}

variable "ipv6_addresses" {
  description = <<EOT
Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface.
EOT
  type    = list(string)
  default = null
  # Provides more control than `ipv6_address_count`. Use when specific IPv6 addresses are required.
  # Example: ["2600:1f16:abcd::1"]
}

variable "key_name" {
  description = <<EOT
Key name of the Key Pair to use for the instance.
The Key Pair can be managed using the `aws_key_pair` resource.
EOT
  type    = string
  default = null
  validation {
    condition     = var.key_name == null || can(regex("^[a-zA-Z0-9-_]+$", var.key_name))
    error_message = "The 'key_name' must be null or a valid key pair name consisting of alphanumeric characters, dashes, or underscores."
  }
  # Essential for SSH access to Linux-based instances. Ensure the key exists in the AWS region.
  # Example: "my-key-pair"
}

variable "launch_template" {
  description = <<EOT
Specifies a Launch Template to configure the instance. 
Parameters configured on this resource will override the corresponding parameters in the Launch Template.
EOT
  type    = map(string)
  default = {}
  # Use Launch Templates for advanced configurations and consistent deployments.
  # Example: { id = "lt-12345678", version = "1" }
}

variable "metadata_options" {
  description = <<EOT
Customize the metadata options of the instance. 
Defines how instance metadata is accessed and its configurations.
EOT
  type    = map(string)
  default = {
    "http_endpoint"               = "enabled"
    "http_put_response_hop_limit" = 1
    "http_tokens"                 = "optional"
  }
  # Configure this for enhanced security, e.g., set 'http_tokens' to 'required' to enforce IMDSv2.
  # Example: { http_endpoint = "enabled", http_tokens = "required", http_put_response_hop_limit = 2 }
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled."
  type        = bool
  default     = null
  # Enable this for detailed CloudWatch metrics. Useful for production workloads.
  # Example: true
}

variable "network_interface" {
  description = <<EOT
Customize network interfaces to be attached at instance boot time.
This includes attributes such as device index, subnet ID, and security groups.
EOT
  type    = list(map(string))
  default = []
  # Use for multi-NIC setups or attaching pre-configured network interfaces.
  # Example: [
  #   { device_index = 0, network_interface_id = "eni-12345678" }
  # ]
}

variable "private_dns_name_options" {
  description = "Customize the private DNS name options of the instance."
  type        = map(string)
  default     = {}
  # Configure this for advanced DNS settings, such as enabling DNS record creation.
  # Example: { hostname_type = "ip-name", enable_resource_name_dns_a_record = true }
}

variable "placement_group" {
  description = "The Placement Group to start the instance in."
  type        = string
  default     = null
  # Specify for tightly coupled workloads requiring low-latency or high-throughput networking.
  # Example: "my-placement-group"
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = null
  # Use this to assign a static private IP within the subnet range.
  # Example: "10.0.0.5"
}

variable "root_block_device" {
  description = <<EOT
Customize details about the root block device of the instance. 
Supports parameters such as size, type, IOPS, encryption, and tags.
EOT
  type    = list(any)
  default = []
  # Configure for custom storage needs, e.g., larger root volume or specific encryption.
  # Example: [
  #   { volume_size = 50, volume_type = "gp3" }
  # ]
}

variable "secondary_private_ips" {
  description = <<EOT
A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. 
This can only be assigned at instance creation.
EOT
  type    = list(string)
  default = null
  # Use when multiple IPs are required on the primary NIC.
  # Example: ["10.0.0.6", "10.0.0.7"]
}

variable "source_dest_check" {
  description = <<EOT
Controls if traffic is routed to the instance when the destination address does not match the instance. 
This is useful for instances acting as NATs or VPNs.
EOT
  type    = bool
  default = null
  # Disable this for NAT gateway or firewall use cases.
  # Example: false
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch the instance in."
  type        = string
  default     = null
  # This variable is essential for placing the instance in the correct network.
  # Example: "subnet-12345678"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
  # Use tags for resource organization, billing, and access control.
  # Example: { "Environment" = "Production", "Application" = "WebApp" }
}

variable "tenancy" {
  description = <<EOT
The tenancy of the instance (if the instance is running in a VPC). 
Available values: 'default', 'dedicated', 'host'.
EOT
  type    = string
  default = null
  validation {
    condition     = var.tenancy == null || contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "The 'tenancy' must be null, 'default', 'dedicated', or 'host'."
  }
  # Use 'dedicated' for compliance or isolation requirements, and 'host' for specific hardware allocation.
  # Example: "dedicated"
}
variable "user_data" {
  description = <<EOT
The user data to provide when launching the instance. 
Do not pass gzip-compressed data via this argument; use `user_data_base64` instead.
EOT
  type    = string
  default = null
  # Use this to provide startup scripts (e.g., shell scripts for Linux or PowerShell for Windows).
  # Ensure scripts are properly encoded and tested for your use case.
  # Example: file("user_data.sh")
}

variable "user_data_base64" {
  description = <<EOT
Base64-encoded binary user data to provide when launching the instance. 
Use this for data that is not a valid UTF-8 string, such as gzip-encoded data.
EOT
  type    = string
  default = null
  # Use this when providing gzip-encoded or other non-UTF-8 user data.
  # Typically generated using base64 encoding tools.
  # Example: base64encode(file("user_data.sh"))
}

variable "user_data_replace_on_change" {
  description = <<EOT
If true, changes to `user_data` or `user_data_base64` will trigger a destroy and recreate of the instance. 
Defaults to false if not set.
EOT
  type    = bool
  default = null
  # Set to `true` for environments where user data changes must reflect immediately.
  # Example: true
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the volumes created by the instance at launch time."
  type        = map(string)
  default     = {}
  # Use this for better identification and management of instance-attached volumes.
  # Example: { "Environment" = "Production", "Team" = "Storage" }
}

variable "enable_volume_tags" {
  description = <<EOT
Whether to enable volume tags for all volumes created with the instance. 
If enabled, it may conflict with `root_block_device` tags.
EOT
  type    = bool
  default = true
  # Useful for consistently applying tags across all instance-attached volumes.
  # Example: true
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = null
  # Security groups control access to the instance. Ensure proper rules are defined.
  # Example: ["sg-12345678", "sg-87654321"]
}

variable "timeouts" {
  description = <<EOT
Define maximum timeout for creating, updating, and deleting EC2 instance resources. 
Use keys 'create', 'update', and 'delete' for specifying timeouts in seconds.
EOT
  type    = map(string)
  default = {}
  # Use this to handle operations that may require longer execution times.
  # Example: { "create" = "10m", "delete" = "5m" }
}

variable "cpu_options" {
  description = "Defines CPU options to apply to the instance at launch time."
  type        = any
  default     = {}
  # Configure for specific CPU optimizations, such as core count and threads per core.
  # Example: { core_count = 4, threads_per_core = 2 }
}

variable "cpu_core_count" {
  description = <<EOT
Sets the number of CPU cores for the instance. 
This is only supported on instance types that support CPU options.
EOT
  type    = number
  default = null
  # Adjust core count for high-performance applications.
  # Example: 4
}

variable "cpu_threads_per_core" {
  description = <<EOT
Sets the number of CPU threads per core for the instance. 
This has no effect unless `cpu_core_count` is also set.
EOT
  type    = number
  default = null
  # Configure for workloads benefiting from multi-threaded operations.
  # Example: 2
}

variable "create_iam_instance_profile" {
  description = <<EOT
Determines whether an IAM instance profile should be created.
- Set to `true` to create a new IAM instance profile along with a new IAM role.
- Set to `false` to use an existing IAM instance profile.
EOT
  type    = bool
  default = false
  # Enable this when no existing IAM instance profile is available for the instance.
  # Example: true
}

variable "iam_role_name" {
  description = <<EOT
Specifies the name to use for the IAM role created. 
If not provided, the `name` variable will be used as the default.
EOT
  type    = string
  default = null
  validation {
    condition     = var.iam_role_name == null || length(var.iam_role_name) <= 128
    error_message = "The 'iam_role_name' must be null or a string with a maximum length of 128 characters."
  }
  # Useful for assigning a descriptive and unique name to the IAM role.
  # Example: "my-ec2-role"
}

variable "iam_role_use_name_prefix" {
  description = <<EOT
Determines whether the specified IAM role name (`iam_role_name` or `name`) should be used as a prefix.
- Set to `true` to append a random string for uniqueness.
- Set to `false` to use the provided name as-is.
EOT
  type    = bool
  default = true
  # Use `true` for environments requiring unique IAM role names.
  # Example: false
}

variable "iam_role_path" {
  description = "Specifies the path for the IAM role. This is useful for organizing IAM resources."
  type        = string
  default     = null
  validation {
    condition     = var.iam_role_path == null || can(regex("^/[a-zA-Z0-9_/]*$", var.iam_role_path))
    error_message = "The 'iam_role_path' must be null or a valid IAM path starting and ending with a forward slash."
  }
  # Organize IAM roles logically, e.g., by department or service.
  # Example: "/service-role/"
}

variable "iam_role_description" {
  description = "Provides a description for the IAM role."
  type        = string
  default     = null
  validation {
    condition     = var.iam_role_description == null || length(var.iam_role_description) <= 256
    error_message = "The 'iam_role_description' must be null or a string with a maximum length of 256 characters."
  }
  # Add a meaningful description to explain the role's purpose.
  # Example: "Role for EC2 instances to access S3 buckets."
}

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
  # Use this for compliance requirements to limit role permissions.
  # Example: "arn:aws:iam::123456789012:policy/permissions-boundary"
}

variable "iam_role_policies" {
  description = <<EOT
A map of policies to attach to the IAM role.
Each policy should be specified with its name as the key and its ARN as the value.
EOT
  type    = map(string)
  default = {}
  # Attach required policies to the role, e.g., S3 or EC2 access.
  # Example: {
  #   "S3FullAccess" = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  #   "EC2FullAccess" = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  # }
}

variable "iam_role_tags" {
  description = "A map of additional tags to assign to the IAM role and instance profile created."
  type        = map(string)
  default     = {}
  # Use tags to track and manage IAM roles effectively.
  # Example: { "Environment" = "Production", "Owner" = "DevOpsTeam" }
}

variable "create_eip" {
  description = <<EOT
Determines whether a public Elastic IP (EIP) will be created and associated with the instance. 
- Set to `true` to create and attach an EIP.
- Set to `false` to skip creating an EIP.
EOT
  type    = bool
  default = false
  # Enable for public-facing instances in a VPC.
  # Example: true
}

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
  # Always set to `vpc` for instances in a VPC.
  # Example: "vpc"
}

variable "eip_tags" {
  description = <<EOT
A map of additional tags to assign to the Elastic IP (EIP). 
These tags can be used for resource management and organization.
EOT
  type    = map(string)
  default = {}
  # Use tags to identify and organize Elastic IPs effectively.
  # Example: { "Environment" = "Production", "Owner" = "NetworkingTeam" }
}
