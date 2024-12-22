

################################################################################
# Auto Scaling Variables
################################################################################


# Variable: instance_type
# Specifies the EC2 instance type for the Auto Scaling Group.
# Default: null
# Example: "t2.micro"
# Constraints: Must be a valid EC2 instance type or null.

variable "instance_type" {
  description = "The type of the EC2 instance to launch in the Auto Scaling Group. Cannot be used with `instance_requirements`."
  type        = string
  default     = null
}

# Variable: ebs_optimized
# Indicates whether the launched EC2 instances will be EBS-optimized.
# Default: null
# Example: true
# Constraints: Must be a boolean value (true/false) or null.

variable "ebs_optimized" {
  description = "Indicates whether to launch EC2 instances with EBS optimization enabled."
  type        = bool
  default     = null
}

# Variable: image_id
# Specifies the AMI ID to use for launching EC2 instances.
# Default: ""
# Example: "ami-0abcdef1234567890"
# Constraints: Must match the AMI ID pattern (starts with "ami-") or be empty.

variable "image_id" {
  description = "The AMI ID used to launch EC2 instances in the Auto Scaling Group."
  type        = string
  default     = ""
  validation {
    condition     = var.image_id == "" || can(regex("^ami-[a-zA-Z0-9]+$", var.image_id))
    error_message = "Image ID must start with 'ami-' or be empty."
  }
}

# Variable: key_name
# Specifies the name of the SSH key pair to use for the instances.
# Default: null
# Example: "my-key-pair"
# Constraints: Must be a valid key pair name or null.

variable "key_name" {
  description = "The name of the SSH key pair to associate with instances for secure access."
  type        = string
  default     = null
}

# Variable: user_data
# Base64-encoded user data to provide during instance launch.
# Default: null
# Example: "#!/bin/bash\necho Hello World > /var/www/html/index.html"
# Constraints: Must be a string or null.

variable "user_data" {
  description = "Base64-encoded user data script to provide during the instance launch for custom initialization."
  type        = string
  default     = null
}


# Variable: availability_zone_distribution
# Configuration for capacity distribution across availability zones.
# Default: {}
# Example: {
#   "capacity_distribution_strategy" = "balanced"
# }
# Constraints: Must be a map containing valid attributes such as "capacity_distribution_strategy".

variable "availability_zone_distribution" {
  description = "Configuration for capacity distribution across availability zones."
  type        = map(any)
  default     = {}
  validation {
    condition     = var.availability_zone_distribution == {} || contains(keys(var.availability_zone_distribution), "capacity_distribution_strategy")
    error_message = "availability_zone_distribution must contain the key 'capacity_distribution_strategy'."
  }
}
# Variable: capacity_rebalance
# Determines whether capacity rebalance is enabled.
# Default: false
# Example: true

variable "capacity_rebalance" {
  description = "Indicates whether capacity rebalance is enabled. Useful for Spot Instances to improve availability during interruptions."
  type        = bool
  default     = false
}

# Variable: min_elb_capacity
# Minimum number of healthy instances in the ELB on creation.
# Default: null
# Example: 1

variable "min_elb_capacity" {
  description = "Minimum number of instances to show up healthy in the ELB only during creation."
  type        = number
  default     = null
}

# Variable: wait_for_elb_capacity
# Exact number of healthy instances to wait for in all attached load balancers.
# Default: null
# Example: 2

variable "wait_for_elb_capacity" {
  description = "Number of healthy instances to wait for in all attached load balancers during creation and updates."
  type        = number
  default     = null
}

# Variable: wait_for_capacity_timeout
# Maximum duration to wait for instances to become healthy.
# Default: null
# Example: "10m" (10 minutes)

variable "wait_for_capacity_timeout" {
  description = "Maximum time to wait for Auto Scaling Group instances to be healthy before timing out."
  type        = string
  default     = null
}

# Variable: default_cooldown
# Time in seconds before another scaling activity can start.
# Default: null
# Example: 300 (5 minutes)

variable "default_cooldown" {
  description = "Cooldown time, in seconds, after a scaling activity completes before another scaling activity can start."
  type        = number
  default     = null
}

# Variable: default_instance_warmup
# Time in seconds for instances to contribute to metrics after launch.
# Default: null
# Example: 300 (5 minutes)

variable "default_instance_warmup" {
  description = "Time until a newly launched instance contributes to metrics, allowing for initialization."
  type        = number
  default     = null
}

# Variable: protect_from_scale_in
# Protect instances from termination during scale-in events.
# Default: false
# Example: true

variable "protect_from_scale_in" {
  description = "Whether instances are protected from termination during scale-in events."
  type        = bool
  default     = false
}

# Variable: placement_group
# Name of the placement group into which instances will be launched.
# Default: null
# Example: "my-placement-group"

variable "placement_group" {
  description = "Specifies the placement group name for instances, if any."
  type        = string
  default     = null
}

# Variable: health_check_type
# Specifies the type of health check to perform.
# Default: null
# Example: "EC2" or "ELB"

variable "health_check_type" {
  description = "Specifies the type of health check to perform. Valid values are `EC2` or `ELB`."
  type        = string
  default     = null
}

# Variable: health_check_grace_period
# Time in seconds before health checks are performed after instance launch.
# Default: null
# Example: 300 (5 minutes)

variable "health_check_grace_period" {
  description = "Time (in seconds) to wait after instance launch before performing health checks."
  type        = number
  default     = null
}

# Variable: force_delete
# Allows forced deletion of the Auto Scaling Group.
# Default: null
# Example: true

variable "force_delete" {
  description = "Whether to force delete the Auto Scaling Group without waiting for instances to terminate."
  type        = bool
  default     = null
}

# Variable: termination_policies
# Policies to determine how instances are terminated.
# Default: []
# Example: ["OldestInstance", "NewestInstance"]

variable "termination_policies" {
  description = "List of termination policies for instances in the Auto Scaling Group."
  type        = list(string)
  default     = []
}

# Variable: suspended_processes
# Processes to suspend in the Auto Scaling Group.
# Default: []
# Example: ["Launch", "Terminate"]

variable "suspended_processes" {
  description = "List of processes to suspend in the Auto Scaling Group. Valid values include `Launch`, `Terminate`, `HealthCheck`, etc."
  type        = list(string)
  default     = []
}

# Variable: max_instance_lifetime
# Maximum time, in seconds, that an instance can remain in service.
# Default: null
# Example: 31536000 (1 year)

variable "max_instance_lifetime" {
  description = "Maximum lifetime, in seconds, for instances in the Auto Scaling Group. Must be 0 or between 86400 and 31536000 seconds."
  type        = number
  default     = null
}

# Variable: enabled_metrics
# Metrics to enable for the Auto Scaling Group.
# Default: []
# Example: ["GroupMinSize", "GroupMaxSize"]

variable "enabled_metrics" {
  description = "List of metrics to enable for monitoring the Auto Scaling Group."
  type        = list(string)
  default     = []
}

# Variable: metrics_granularity
# Specifies the granularity of metrics to collect.
# Default: null
# Example: "1Minute"

variable "metrics_granularity" {
  description = "Granularity of metrics to collect for the Auto Scaling Group. Default is `1Minute`."
  type        = string
  default     = null
}

# Variable: service_linked_role_arn
# ARN of the service-linked role for the Auto Scaling Group.
# Default: null
# Example: "arn:aws:iam::123456789012:role/service-role/AWSServiceRoleForAutoScaling"

variable "service_linked_role_arn" {
  description = "ARN of the service-linked role for the Auto Scaling Group to interact with other AWS services."
  type        = string
  default     = null
}

# Variable: initial_lifecycle_hooks
# List of lifecycle hooks to attach to the Auto Scaling Group.
# Default: []
# Example: [{"name": "my-hook", "lifecycle_transition": "autoscaling:EC2_INSTANCE_LAUNCHING"}]

variable "initial_lifecycle_hooks" {
  description = "List of lifecycle hooks to attach to the Auto Scaling Group."
  type        = list(map(string))
  default     = []
}


# Variable: ignore_desired_capacity_changes
# Determines whether the `desired_capacity` value is ignored after the initial apply.
# Default: false
# Example: true (if you want to maintain the desired capacity from the first apply).

variable "ignore_desired_capacity_changes" {
  description = "Determines whether the `desired_capacity` value is ignored after initial apply. Useful when desired_capacity should not dynamically change."
  type        = bool
  default     = false
}

# Variable: name
# The name used across the resources created.
# Default: Must be provided.
# Example: "autoscaling-group-name"

variable "name" {
  description = "The name used across the resources created."
  type        = string
}

# Variable: use_name_prefix
# Determines whether to use `name` as is or create a unique name starting with `name` as a prefix.
# Default: true
# Example: false (if you want to use the exact `name` without prefixes).

variable "use_name_prefix" {
  description = "Determines whether to use `name` as is or create a unique name beginning with `name` as the prefix."
  type        = bool
  default     = true
}

# Variable: instance_name
# Specifies the name tag propagated to instances. Defaults to `var.name` if not set.
# Default: "" (empty string, uses `var.name`).
# Example: "web-instance"

variable "instance_name" {
  description = "The name tag applied to EC2 instances. Defaults to the value of `var.name` if not explicitly set."
  type        = string
  default     = ""
}

# Variable: launch_template_id
# Specifies the ID of an existing launch template to use.
# Default: null
# Example: "lt-0abcd1234efgh5678"

variable "launch_template_id" {
  description = "ID of an existing launch template to use. Must be provided if creating resources based on a pre-existing launch template."
  type        = string
  default     = null
}

# Variable: launch_template_version
# Version of the launch template to use.
# Default: null
# Example: "$Latest" or "$Default" or a specific version like "1".

variable "launch_template_version" {
  description = "Specifies the version of the launch template to use. Can be set to `$Latest`, `$Default`, or a specific version number."
  type        = string
  default     = null
}

# Variable: availability_zones
# Specifies a list of one or more availability zones for the group. Conflicts with `vpc_zone_identifier`.
# Default: null
# Example: ["us-east-1a", "us-east-1b"]

variable "availability_zones" {
  description = "A list of one or more availability zones for the Auto Scaling Group. Conflicts with `vpc_zone_identifier`."
  type        = list(string)
  default     = null
}

# Variable: vpc_zone_identifier
# List of subnet IDs to launch resources in. Overrides `availability_zones`.
# Default: null
# Example: ["subnet-0123456789abcdef", "subnet-abcdef0123456789"]

variable "vpc_zone_identifier" {
  description = "List of subnet IDs to launch resources in. Overrides `availability_zones` if specified."
  type        = list(string)
  default     = null
}

# Variable: min_size
# The minimum number of instances in the Auto Scaling Group.
# Default: Must be provided.
# Example: 1

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group. Must be a non-negative integer."
  type        = number
}

# Variable: max_size
# The maximum number of instances in the Auto Scaling Group.
# Default: Must be provided.
# Example: 10

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group. Must be a non-negative integer greater than or equal to `min_size`."
  type        = number
}

# Variable: desired_capacity
# Specifies the desired number of instances in the Auto Scaling Group.
# Default: null (calculated dynamically if not set).
# Example: 5

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group. Must be between `min_size` and `max_size`."
  type        = number
  default     = null
}

# Variable: desired_capacity_type
# Specifies the unit of measurement for the desired capacity.
# Default: null
# Example: "units", "vcpu", "memory-mib"

variable "desired_capacity_type" {
  description = "Specifies the unit of measurement for the desired capacity. Valid values are `units`, `vcpu`, `memory-mib`."
  type        = string
  default     = null
}


# Variable: instance_refresh
# If configured, triggers an Instance Refresh when the Auto Scaling Group is updated.
# Default: {}
# Example: {"strategy": "Rolling", "min_healthy_percentage": 90}
# Constraints: Must contain "strategy" with valid values ("Rolling", "Immutable") and "min_healthy_percentage" (integer between 0 and 100).

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated."
  type        = map(any)
  default     = {}
  validation {
    condition     = var.instance_refresh == {} || (
      contains(keys(var.instance_refresh), "strategy") &&
      contains(["Rolling", "Immutable"], var.instance_refresh["strategy"]) &&
      contains(keys(var.instance_refresh), "min_healthy_percentage") &&
      var.instance_refresh["min_healthy_percentage"] >= 0 &&
      var.instance_refresh["min_healthy_percentage"] <= 100
    )
    error_message = "Instance Refresh must contain valid strategy (Rolling or Immutable) and a min_healthy_percentage between 0 and 100."
  }
}

# Variable: use_mixed_instances_policy
# Determines whether to enable a mixed instances policy in the Auto Scaling Group.
# Default: false
# Example: true.
# Constraints: Must be a boolean value (true/false).

variable "use_mixed_instances_policy" {
  description = "Determines whether to use a mixed instances policy in the autoscaling group or not."
  type        = bool
  default     = false
  validation {
    condition     = var.use_mixed_instances_policy == true || var.use_mixed_instances_policy == false
    error_message = "Use mixed instances policy must be either true or false."
  }
}

# Variable: mixed_instances_policy
# Configures settings for launching diverse instance types in the Auto Scaling Group.
# Default: null
# Example: {
#   "instances_distribution" = {
#     "on_demand_percentage_above_base_capacity" = 50,
#     "spot_allocation_strategy" = "lowest-price"
#   },
#   "launch_template" = {
#     "launch_template_specification" = {
#       "launch_template_id" = "lt-0123456789abcdef",
#       "version" = "$Latest"
#     },
#     "overrides" = [
#       {
#         "instance_type" = "t2.micro"
#       }
#     ]
#   }
# }
# Constraints: Must contain "instances_distribution" and "launch_template" with required attributes.

variable "mixed_instances_policy" {
  description = "Configuration block containing settings to define launch targets for Auto Scaling groups."
  type        = map(any)
  default     = null
  validation {
    condition     = var.mixed_instances_policy == null || (
      contains(keys(var.mixed_instances_policy), "instances_distribution") &&
      contains(keys(var.mixed_instances_policy), "launch_template")
    )
    error_message = "Mixed Instances Policy must contain instances_distribution and launch_template configurations if not null."
  }
}

# Variable: delete_timeout
# Specifies the timeout duration for deleting the Auto Scaling Group.
# Default: null
# Example: "15m" (15 minutes).
# Constraints: Must be a valid duration string (e.g., "5m", "1h") or null.

variable "delete_timeout" {
  description = "Delete timeout to wait for destroying autoscaling group."
  type        = string
  default     = null
  validation {
    condition     = var.delete_timeout == null || can(regex("^[0-9]+[smhd]$", var.delete_timeout))
    error_message = "Delete timeout must be a valid duration string (e.g., '5m', '1h')."
  }
}

# Variable: tags
# Specifies a map of tags to assign to resources managed by the Auto Scaling Group.
# Default: {}
# Example: {"Environment": "Production", "Team": "DevOps"}.
# Constraints: Keys and values must be non-empty strings.

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.tags : length(k) > 0 && length(v) > 0])
    error_message = "Tags must have non-empty keys and values."
  }
}

# Variable: warm_pool
# Configures a warm pool for the Auto Scaling Group.
# Default: {}
# Example: {
#   "pool_state" = "Stopped",
#   "min_size" = 2,
#   "max_size" = 5
# }
# Constraints: Must contain valid attributes like "pool_state" ("Stopped" or "Running") and numeric sizes.

variable "warm_pool" {
  description = "If this block is configured, add a Warm Pool to the specified Auto Scaling group."
  type        = map(any)
  default     = {}
  validation {
    condition     = var.warm_pool == {} || (
      contains(keys(var.warm_pool), "pool_state") &&
      contains(["Stopped", "Running"], var.warm_pool["pool_state"])
    )
    error_message = "Warm Pool must contain a valid pool_state (Stopped or Running)."
  }
}

# Variable: image_id
# Specifies the AMI ID to launch the EC2 instances.
# Default: ""
# Example: "ami-0abcdef1234567890".
# Constraints: Must match the AMI ID pattern (starts with "ami-") or be empty.

variable "image_id" {
  description = "The AMI from which to launch the instance."
  type        = string
  default     = ""
  validation {
    condition     = var.image_id == "" || can(regex("^ami-[a-zA-Z0-9]+$", var.image_id))
    error_message = "Image ID must start with 'ami-' or be empty."
  }
}

# Variable: instance_requirements
# Specifies instance attribute requirements for launching.
# Default: {}
# Example: {
#   "vcpu_count" = {"min" = 1, "max" = 2},
#   "memory_mib" = {"min" = 1024, "max" = 2048}
# }
# Constraints: Must be a map containing valid numeric ranges for attributes like vcpu_count and memory_mib.

variable "instance_requirements" {
  description = "The attribute requirements for the type of instance. If present then `instance_type` cannot be present."
  type        = map(any)
  default     = {}
  validation {
    condition     = var.instance_requirements == {} || (
      contains(keys(var.instance_requirements), "vcpu_count") &&
      contains(keys(var.instance_requirements), "memory_mib")
    )
    error_message = "Instance requirements must contain vcpu_count and memory_mib if not empty."
  }
}

# Variable: security_groups
# A list of security group IDs to associate with the Auto Scaling Group.
# Default: []
# Example: ["sg-0123456789abcdef"]
# Constraints: Must be a list of strings starting with "sg-".

variable "security_groups" {
  description = "A list of security group IDs to associate."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for sg in var.security_groups : can(regex("^sg-[a-zA-Z0-9]+$", sg))])
    error_message = "Each security group ID must start with 'sg-'."
  }
}


# Variable: enable_monitoring
# Enables or disables detailed monitoring for EC2 instances.
# Default: true
# Example: false
# Constraints: Must be a boolean value (true/false).

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring."
  type        = bool
  default     = true
  validation {
    condition     = var.enable_monitoring == true || var.enable_monitoring == false
    error_message = "Enable monitoring must be either true or false."
  }
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
# Variable: autoscaling_group_tags
# Specifies additional tags for the Auto Scaling Group.
# Default: {}
# Example: {"Environment": "Staging", "Owner": "Admin"}.
# Constraints: Keys and values must be non-empty strings.

variable "autoscaling_group_tags" {
  description = "A map of additional tags to add to the autoscaling group."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.autoscaling_group_tags : length(k) > 0 && length(v) > 0])
    error_message = "Auto Scaling Group tags must have non-empty keys and values."
  }
}

# Variable: ignore_failed_scaling_activities
# Determines whether to ignore failed scaling activities during capacity waits.
# Default: false
# Example: true
# Constraints: Must be a boolean value (true/false).

variable "ignore_failed_scaling_activities" {
  description = "Whether to ignore failed Auto Scaling scaling activities while waiting for capacity. The default is false -- failed scaling activities cause errors to be returned."
  type        = bool
  default     = false
  validation {
    condition     = var.ignore_failed_scaling_activities == true || var.ignore_failed_scaling_activities == false
    error_message = "Ignore failed scaling activities must be either true or false."
  }
}

# Variable: instance_maintenance_policy
# Configures an instance maintenance policy for the Auto Scaling Group.
# Default: {}
# Example: {"auto_recovery" = true}.
# Constraints: Must be a map with valid attributes like "auto_recovery".

variable "instance_maintenance_policy" {
  description = "If this block is configured, add an instance maintenance policy to the specified Auto Scaling group."
  type        = map(any)
  default     = {}
  validation {
    condition     = var.instance_maintenance_policy == {} || contains(keys(var.instance_maintenance_policy), "auto_recovery")
    error_message = "Instance maintenance policy must contain a valid 'auto_recovery' attribute if not empty."
  }
}

################################################################################
# Launch Template
################################################################################

# Variable: create_launch_template
# Determines whether to create a launch template.
# Default: true
# Example: false
# Constraints: Must be a boolean value (true/false).

variable "create_launch_template" {
  description = "Determines whether to create a launch template or not."
  type        = bool
  default     = true
}

# Variable: launch_template_name
# Name of the launch template to be created.
# Default: "" (empty string).
# Example: "my-launch-template"
# Constraints: Must be a string.

variable "launch_template_name" {
  description = "Name of the launch template to be created."
  type        = string
  default     = ""
}

# Variable: launch_template_use_name_prefix
# Determines whether to use `launch_template_name` as is or as a prefix for a unique name.
# Default: true
# Example: false
# Constraints: Must be a boolean value (true/false).

variable "launch_template_use_name_prefix" {
  description = "Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix."
  type        = bool
  default     = true
}

# Variable: launch_template_description
# Description of the launch template.
# Default: null
# Example: "Launch template for web instances"
# Constraints: Must be a string or null.

variable "launch_template_description" {
  description = "Description of the launch template."
  type        = string
  default     = null
}

# Variable: default_version
# Default version of the launch template.
# Default: null
# Example: "1"
# Constraints: Must be a string or null.

variable "default_version" {
  description = "Default version of the launch template."
  type        = string
  default     = null
}

# Variable: update_default_version
# Determines whether to update the default version on each update.
# Default: null
# Example: true
# Constraints: Must be a boolean value (true/false) or null. Conflicts with `default_version`.

variable "update_default_version" {
  description = "Whether to update the default version on each update. Conflicts with `default_version`."
  type        = bool
  default     = null
}

# Variable: disable_api_termination
# Enables EC2 instance termination protection.
# Default: null
# Example: true
# Constraints: Must be a boolean value (true/false) or null.

variable "disable_api_termination" {
  description = "If true, enables EC2 instance termination protection."
  type        = bool
  default     = null
}

# Variable: disable_api_stop
# Enables EC2 instance stop protection.
# Default: null
# Example: true
# Constraints: Must be a boolean value (true/false) or null.

variable "disable_api_stop" {
  description = "If true, enables EC2 instance stop protection."
  type        = bool
  default     = null
}

# Variable: instance_initiated_shutdown_behavior
# Determines the shutdown behavior for the instance.
# Default: null
# Example: "stop"
# Constraints: Must be one of "stop" or "terminate" or null.

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)"
  type        = string
  default     = null
}

# Variable: kernel_id
# Kernel ID for the instance.
# Default: null
# Example: "aki-12345678"
# Constraints: Must be a string or null.

variable "kernel_id" {
  description = "The kernel ID for the instance."
  type        = string
  default     = null
}

# Variable: ram_disk_id
# RAM disk ID for the instance.
# Default: null
# Example: "ari-12345678"
# Constraints: Must be a string or null.

variable "ram_disk_id" {
  description = "The ID of the RAM disk for the instance."
  type        = string
  default     = null
}

# Variable: block_device_mappings
# Specify volumes to attach to the instance beyond the AMI-defined volumes.
# Default: []
# Example: [{"device_name": "/dev/sda1", "volume_size": 30}]
# Constraints: Must be a list of mappings or empty.

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI."
  type        = list(any)
  default     = []
}

# Variable: capacity_reservation_specification
# Targeting for EC2 capacity reservations.
# Default: {}
# Example: {"capacity_reservation_preference": "open"}
# Constraints: Must be a valid map or empty.

variable "capacity_reservation_specification" {
  description = "Targeting for EC2 capacity reservations."
  type        = any
  default     = {}
}

# Variable: cpu_options
# Specifies the CPU options for the instance.
# Default: {}
# Example: {"core_count": "4", "threads_per_core": "2"}
# Constraints: Must be a map of valid CPU options or empty.

variable "cpu_options" {
  description = "The CPU options for the instance."
  type        = map(string)
  default     = {}
}

# Variable: credit_specification
# Specifies the credit specification for the instance.
# Default: {}
# Example: {"cpu_credits": "unlimited"}
# Constraints: Must be a map of valid credit specifications or empty.

variable "credit_specification" {
  description = "Customize the credit specification of the instance."
  type        = map(string)
  default     = {}
}

# Variable: elastic_gpu_specifications
# Attaches an elastic GPU to the instance.
# Default: {}
# Example: {"type": "eg1.medium"}
# Constraints: Must be a map of valid GPU specifications or empty.

variable "elastic_gpu_specifications" {
  description = "The elastic GPU to attach to the instance."
  type        = map(string)
  default     = {}
}

# Variable: elastic_inference_accelerator
# Specifies an Elastic Inference Accelerator for the instance.
# Default: {}
# Example: {"type": "eia2.medium"}
# Constraints: Must be a map of valid accelerator specifications or empty.

variable "elastic_inference_accelerator" {
  description = "Configuration block containing an Elastic Inference Accelerator to attach to the instance."
  type        = map(string)
  default     = {}
}

# Variable: enclave_options
# Enables Nitro Enclaves on launched instances.
# Default: {}
# Example: {"enabled": "true"}
# Constraints: Must be a map or empty.

variable "enclave_options" {
  description = "Enable Nitro Enclaves on launched instances."
  type        = map(string)
  default     = {}
}

# Variable: hibernation_options
# Specifies hibernation options for the instance.
# Default: {}
# Example: {"configured": "true"}
# Constraints: Must be a map or empty.

variable "hibernation_options" {
  description = "The hibernation options for the instance."
  type        = map(string)
  default     = {}
}

# Variable: instance_market_options
# Specifies the market (purchasing) options for the instance.
# Default: {}
# Example: {"market_type": "spot"}
# Constraints: Must be a valid map or empty.

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance."
  type        = any
  default     = {}
}

# Variable: license_specifications
# Specifies license specifications to associate with the instance.
# Default: {}
# Example: {"license_configuration_arn": "arn:aws:license-manager:region:account:license-configuration:license-id"}
# Constraints: Must be a valid map or empty.

variable "license_specifications" {
  description = "A list of license specifications to associate with."
  type        = map(string)
  default     = {}
}

# Variable: maintenance_options
# Specifies maintenance options for the instance.
# Default: {}
# Example: {"auto_recovery": "enabled"}
# Constraints: Must be a map or empty.

variable "maintenance_options" {
  description = "The maintenance options for the instance."
  type        = any
  default     = {}
}

################################################################################
# Complete variables.tf file with Validation, Defaults, Examples, and Comments
################################################################################

# Variable: network_interfaces
# Customizes network interfaces for the instance.
# Default: []
# Example: [{"device_index": 0, "subnet_id": "subnet-0123456789abcdef"}]
# Constraints: Must be a list of valid network interface configurations or empty.

variable "network_interfaces" {
  description = "Customize network interfaces to be attached at instance boot time."
  type        = list(any)
  default     = []
}

# Variable: placement
# Specifies the placement configuration for the instance.
# Default: {}
# Example: {"availability_zone": "us-east-1a", "tenancy": "default"}
# Constraints: Must be a valid map or empty.

variable "placement" {
  description = "The placement configuration for the instance."
  type        = map(string)
  default     = {}
}

# Variable: private_dns_name_options
# Configures the options for the instance's private DNS name.
# Default: {}
# Example: {"enable_resource_name_dns_a_record": true, "hostname_type": "ip-name"}
# Constraints: Must be a valid map or empty.

variable "private_dns_name_options" {
  description = "The options for the instance's private DNS name."
  type        = map(string)
  default     = {}
}

# Variable: tag_specifications
# Specifies tags to apply to resources during launch.
# Default: []
# Example: [{"resource_type": "instance", "tags": {"Name": "web-instance", "Environment": "production"}}]
# Constraints: Must be a list of valid tag specifications or empty.

variable "tag_specifications" {
  description = "The tags to apply to the resources during launch."
  type        = list(any)
  default     = []
}

################################################################################
# Autoscaling group traffic source attachment
################################################################################

# Variable: traffic_source_attachments
# Map of traffic source attachment definitions to create.
# Default: {}
# Example: {"target_group_arn": "arn:aws:elasticloadbalancing:region:account:targetgroup/example"}
# Constraints: Must be a valid map or empty.

variable "traffic_source_attachments" {
  description = "Map of traffic source attachment definitions to create."
  type        = any
  default     = {}
}

################################################################################
# Autoscaling group schedule
################################################################################

# Variable: create_schedule
# Determines whether to create an autoscaling group schedule.
# Default: true
# Example: false
# Constraints: Must be a boolean value (true/false).

variable "create_schedule" {
  description = "Determines whether to create an autoscaling group schedule or not."
  type        = bool
  default     = true
}

# Variable: schedules
# Map of autoscaling group schedules to create.
# Default: {}
# Example: {"daily-scale-up": {"scheduled_action_name": "daily-scale-up", "start_time": "2023-01-01T00:00:00Z", "desired_capacity": 5}}
# Constraints: Must be a valid map or empty.

variable "schedules" {
  description = "Map of autoscaling group schedules to create."
  type        = map(any)
  default     = {}
}

################################################################################
# Autoscaling policy
################################################################################

# Variable: create_scaling_policy
# Determines whether to create a scaling policy for the autoscaling group.
# Default: true
# Example: false
# Constraints: Must be a boolean value (true/false).

variable "create_scaling_policy" {
  description = "Determines whether to create a scaling policy for the autoscaling group or not."
  type        = bool
  default     = true
}

# Variable: scaling_policies
# Map of scaling policy configurations to create.
# Default: {}
# Example: {"scale-up": {"policy_type": "TargetTrackingScaling", "target_value": 50, "cooldown": 300}}
# Constraints: Must be a valid map or empty.

variable "scaling_policies" {
  description = "Map of scaling policy configurations to create."
  type        = any
  default     = {}
}
################################################################################
# Complete variables.tf file with Validation, Defaults, Examples, and Comments
################################################################################

# Variable: elastic_inference_accelerator
# Specifies an Elastic Inference Accelerator for the instance.
# Default: {}
# Example: {"type": "eia2.medium"}
# Constraints: Must be a map of valid accelerator specifications or empty.

variable "elastic_inference_accelerator" {
  description = "Configuration block containing an Elastic Inference Accelerator to attach to the instance."
  type        = map(string)
  default     = {}
}

# Variable: enclave_options
# Enables Nitro Enclaves on launched instances.
# Default: {}
# Example: {"enabled": true}
# Constraints: Must be a valid map or empty.

variable "enclave_options" {
  description = "Enable Nitro Enclaves on launched instances."
  type        = map(string)
  default     = {}
}

# Variable: hibernation_options
# Specifies hibernation options for the instance.
# Default: {}
# Example: {"configured": true}
# Constraints: Must be a valid map or empty.

variable "hibernation_options" {
  description = "The hibernation options for the instance."
  type        = map(string)
  default     = {}
}

# Variable: instance_market_options
# Specifies the market (purchasing) options for the instance.
# Default: {}
# Example: {"market_type": "spot"}
# Constraints: Must be a valid map or empty.

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance."
  type        = any
  default     = {}
}

# Variable: license_specifications
# Specifies license specifications to associate with the instance.
# Default: {}
# Example: {"license_configuration_arn": "arn:aws:license-manager:region:account:license-configuration:license-id"}
# Constraints: Must be a valid map or empty.

variable "license_specifications" {
  description = "A list of license specifications to associate with."
  type        = map(string)
  default     = {}
}

# Variable: maintenance_options
# Specifies maintenance options for the instance.
# Default: {}
# Example: {"auto_recovery": "enabled"}
# Constraints: Must be a valid map or empty.

variable "maintenance_options" {
  description = "The maintenance options for the instance."
  type        = any
  default     = {}
}

# Variable: block_device_mappings
# Specifies additional volumes to attach to the instance.
# Default: []
# Example: [{"device_name": "/dev/sda1", "volume_size": 30}]
# Constraints: Must be a list of valid volume configurations or empty.

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI."
  type        = list(any)
  default     = []
}

# Variable: capacity_reservation_specification
# Specifies capacity reservation targeting for the instance.
# Default: {}
# Example: {"capacity_reservation_preference": "open"}
# Constraints: Must be a valid map or empty.

variable "capacity_reservation_specification" {
  description = "Targeting for EC2 capacity reservations."
  type        = any
  default     = {}
}

# Variable: cpu_options
# Specifies CPU options for the instance.
# Default: {}
# Example: {"core_count": 4, "threads_per_core": 2}
# Constraints: Must be a valid map or empty.

variable "cpu_options" {
  description = "The CPU options for the instance."
  type        = map(string)
  default     = {}
}

# Variable: credit_specification
# Specifies credit options for burstable performance instances.
# Default: {}
# Example: {"cpu_credits": "unlimited"}
# Constraints: Must be a valid map or empty.

variable "credit_specification" {
  description = "Customize the credit specification of the instance."
  type        = map(string)
  default     = {}
}


################################################################################
# Complete variables.tf file with Validation, Defaults, Examples, and Comments
################################################################################

# Variable: create_iam_instance_profile
# Determines whether an IAM instance profile is created or an existing one is used.
# Default: false
# Example: true
# Constraints: Must be a boolean value (true/false).

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile."
  type        = bool
  default     = false
}

# Variable: iam_instance_profile_arn
# ARN of an existing IAM instance profile. Used when `create_iam_instance_profile` is false.
# Default: null
# Example: "arn:aws:iam::123456789012:instance-profile/my-instance-profile"
# Constraints: Must be a valid IAM instance profile ARN or null.

variable "iam_instance_profile_arn" {
  description = "Amazon Resource Name (ARN) of an existing IAM instance profile. Used when `create_iam_instance_profile` = `false`."
  type        = string
  default     = null
}

# Variable: iam_instance_profile_name
# Name of the IAM instance profile to create or use.
# Default: null
# Example: "my-instance-profile"
# Constraints: Must be a string or null.

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to be created (`create_iam_instance_profile` = `true`) or existing (`create_iam_instance_profile` = `false`)."
  type        = string
  default     = null
}

# Variable: iam_role_name
# Name to assign to the IAM role.
# Default: null
# Example: "my-iam-role"
# Constraints: Must be a string or null.

variable "iam_role_name" {
  description = "Name to use on IAM role created."
  type        = string
  default     = null
}

# Variable: iam_role_use_name_prefix
# Determines whether to use `iam_role_name` as a prefix for the IAM role name.
# Default: true
# Example: false
# Constraints: Must be a boolean value (true/false).

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix."
  type        = bool
  default     = true
}

# Variable: iam_role_path
# Specifies the path for the IAM role.
# Default: null
# Example: "/service-roles/"
# Constraints: Must be a valid IAM path or null.

variable "iam_role_path" {
  description = "IAM role path."
  type        = string
  default     = null
}

# Variable: iam_role_description
# Description for the IAM role.
# Default: null
# Example: "IAM role for managing EC2 instances."
# Constraints: Must be a string or null.

variable "iam_role_description" {
  description = "Description of the role."
  type        = string
  default     = null
}

# Variable: iam_role_permissions_boundary
# ARN of the policy used as the permissions boundary for the IAM role.
# Default: null
# Example: "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
# Constraints: Must be a valid policy ARN or null.

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role."
  type        = string
  default     = null
}

# Variable: iam_role_policies
# Specifies the IAM policies to attach to the IAM role.
# Default: {}
# Example: {"S3FullAccess": "arn:aws:iam::aws:policy/AmazonS3FullAccess"}
# Constraints: Must be a map of policy names to ARNs or empty.

variable "iam_role_policies" {
  description = "IAM policies to attach to the IAM role."
  type        = map(string)
  default     = {}
}

# Variable: iam_role_tags
# Tags to attach to the IAM role.
# Default: {}
# Example: {"Environment": "Production", "Team": "DevOps"}
# Constraints: Must be a map of key-value pairs or empty.

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created."
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