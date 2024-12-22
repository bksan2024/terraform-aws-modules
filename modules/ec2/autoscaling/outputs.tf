################################################################################
# Outputs for Launch Template
################################################################################

output "launch_template_id" {
  description = "The unique identifier (ID) of the created launch template, used to reference it in other resources."
  value       = try(aws_launch_template.this[0].id, null)
}

output "launch_template_arn" {
  description = "The Amazon Resource Name (ARN) of the launch template, a globally unique identifier for AWS resources."
  value       = try(aws_launch_template.this[0].arn, null)
}

output "launch_template_name" {
  description = "The name assigned to the launch template, used for identifying it within your AWS environment."
  value       = try(aws_launch_template.this[0].name, null)
}

output "launch_template_latest_version" {
  description = "The version number of the most recent update to the launch template."
  value       = try(aws_launch_template.this[0].latest_version, null)
}

output "launch_template_default_version" {
  description = "The version number marked as the default for the launch template, used if no specific version is specified."
  value       = try(aws_launch_template.this[0].default_version, null)
}

################################################################################
# Outputs for Autoscaling Group
################################################################################

output "autoscaling_group_id" {
  description = "The unique ID of the created Auto Scaling Group, used to reference it in other configurations."
  value       = try(aws_autoscaling_group.this[0].id, aws_autoscaling_group.idc[0].id, null)
}

output "autoscaling_group_name" {
  description = "The name assigned to the Auto Scaling Group for identification within AWS."
  value       = try(aws_autoscaling_group.this[0].name, aws_autoscaling_group.idc[0].name, null)
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling Group, a unique resource identifier."
  value       = try(aws_autoscaling_group.this[0].arn, aws_autoscaling_group.idc[0].arn, null)
}

output "autoscaling_group_min_size" {
  description = "The minimum number of instances the group will maintain."
  value       = try(aws_autoscaling_group.this[0].min_size, aws_autoscaling_group.idc[0].min_size, null)
}

output "autoscaling_group_max_size" {
  description = "The maximum number of instances the group can scale up to."
  value       = try(aws_autoscaling_group.this[0].max_size, aws_autoscaling_group.idc[0].max_size, null)
}

output "autoscaling_group_desired_capacity" {
  description = "The target number of instances that should be running in the group."
  value       = try(aws_autoscaling_group.this[0].desired_capacity, aws_autoscaling_group.idc[0].desired_capacity, null)
}

output "autoscaling_group_default_cooldown" {
  description = "The time (in seconds) to wait between scaling activities."
  value       = try(aws_autoscaling_group.this[0].default_cooldown, aws_autoscaling_group.idc[0].default_cooldown, null)
}

output "autoscaling_group_health_check_grace_period" {
  description = "The time (in seconds) before performing health checks after launching an instance."
  value       = try(aws_autoscaling_group.this[0].health_check_grace_period, aws_autoscaling_group.idc[0].health_check_grace_period, null)
}

output "autoscaling_group_health_check_type" {
  description = "The type of health checks performed (EC2 or ELB)."
  value       = try(aws_autoscaling_group.this[0].health_check_type, aws_autoscaling_group.idc[0].health_check_type, null)
}

output "autoscaling_group_availability_zones" {
  description = "The list of availability zones where the Auto Scaling Group can deploy instances."
  value       = try(aws_autoscaling_group.this[0].availability_zones, aws_autoscaling_group.idc[0].availability_zones, [])
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "The list of VPC subnet IDs associated with the Auto Scaling Group."
  value       = try(aws_autoscaling_group.this[0].vpc_zone_identifier, aws_autoscaling_group.idc[0].vpc_zone_identifier, [])
}

output "autoscaling_group_load_balancers" {
  description = "The names of load balancers attached to the Auto Scaling Group."
  value       = try(aws_autoscaling_group.this[0].load_balancers, aws_autoscaling_group.idc[0].load_balancers, [])
}

output "autoscaling_group_target_group_arns" {
  description = "The ARNs of target groups associated with the Auto Scaling Group."
  value       = try(aws_autoscaling_group.this[0].target_group_arns, aws_autoscaling_group.idc[0].target_group_arns, [])
}

output "autoscaling_group_enabled_metrics" {
  description = "A list of metrics enabled for monitoring the Auto Scaling Group."
  value       = try(aws_autoscaling_group.this[0].enabled_metrics, aws_autoscaling_group.idc[0].enabled_metrics, [])
}

################################################################################
# Outputs for Autoscaling Group Schedule
################################################################################

output "autoscaling_schedule_arns" {
  description = "A map of ARNs for all Auto Scaling Group schedules."
  value       = { for k, v in aws_autoscaling_schedule.this : k => v.arn }
}

################################################################################
# Outputs for Autoscaling Policy
################################################################################

output "autoscaling_policy_arns" {
  description = "A map of ARNs for all Auto Scaling policies."
  value       = { for k, v in aws_autoscaling_policy.this : k => v.arn }
}

################################################################################
# Outputs for IAM Role / Instance Profile
################################################################################

output "iam_role_name" {
  description = "The name of the created IAM role, used for reference in other resources."
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_arn" {
  description = "The ARN of the IAM role, a unique identifier for the role."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_unique_id" {
  description = "A stable, unique string that identifies the IAM role."
  value       = try(aws_iam_role.this[0].unique_id, null)
}

output "iam_instance_profile_arn" {
  description = "The ARN of the created or provided IAM instance profile."
  value       = try(aws_iam_instance_profile.this[0].arn, var.iam_instance_profile_arn)
}

output "iam_instance_profile_id" {
  description = "The unique ID of the IAM instance profile."
  value       = try(aws_iam_instance_profile.this[0].id, null)
}

output "iam_instance_profile_unique" {
  description = "A stable, unique string identifying the IAM instance profile."
  value       = try(aws_iam_instance_profile.this[0].unique_id, null)
}
