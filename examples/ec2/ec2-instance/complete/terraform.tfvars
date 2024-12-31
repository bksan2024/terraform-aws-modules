
region                   = "ca-central-1"
profile                  = "poc-sandbox" #it is for AWS CLI authentication for local validation and not required for Pipelines
#provider_version         = "~> 5.0"
#name                         = "awlappturborm01"

###Instance Name Tagging varables###########################################################################
default_tags = {
  "Application" = "Citrix-Test",
  "Environment" = "prod"
  "Project"     = "GB-GPM"
  "Region"      = "Ca-Central-1"
}

security_group_tags = {
  "name" = "citrixfirewall",
  "purpose" = "Restrict Access",
  "Application" = "Citrix-Test"

}
provider_name    = "aw"
os_family          = "l"
server_type = "ap"
environment_name = "p"
purpose = "turborm"
additional_tags = {
  Team = "DevOps"
  CostCenter = "12345"
}

instances = {
  00 = {
    ami             = "ami-0a590ca28046d073e"
    instance_type   = "t2.micro"
    key_name        = "test"


root_block_device = {

    delete_on_termination = true
    encrypted             = true
    iops                  = 1000
    kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"
    volume_size           = 50
    volume_type           = "gp3"
    throughput            = 125
    root_block_device_tags = {
  "root_volume_name" = "ebs-os-cac-production-awwappturborm01-100",
  "root_volume_size" = "50GB"
  
}
  }

ebs_block_device = [
  {
    delete_on_termination = true  # Delete the volume on instance termination
    device_name           = "/dev/sdh"  # Device name (e.g., /dev/sdh)
    encrypted             = true  # Encrypt the volume
    iops                  = 3000  # IOPS for the volume (optional, relevant for io1, io2)
    kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"  # KMS key ID for encryption (optional)
    snapshot_id           = null  # Snapshot ID (optional)
    volume_size           = 100  # Size of the volume in GB
    volume_type           = "gp3"  # Volume type (e.g., gp2, gp3, io1, io2, sc1, st1, standard)
    throughput            = 125  # Throughput for the volume in MB/s (optional, relevant for gp3)
    ebs_block_device_tags                  = { 
      ebs_volume_id = "1"
      ebs-volme_size = "100GB"
      ebs_volume_name    = "EBS-OS-USE-AWLAPPTURBORM01-100"
    }

  }
]

    additional_tags = {
      Role = "VDI-Test-1"
    }
  },
  01 = {
    ami             = "ami-0a590ca28046d073e"
    instance_type   = "t2.micro"
    key_name        = "test"


root_block_device = {

    delete_on_termination = true
    encrypted             = true
    iops                  = 1000
    kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"
    volume_size           = 50
    volume_type           = "gp3"
    throughput            = 125
    root_block_device_tags = {
  "root_volume_name" = "ebs-os-cac-production-awwappturborm02-100",
  "root_volume_size" = "50GB"
  
}
  }
ebs_block_device = [
  {
    delete_on_termination = true  # Delete the volume on instance termination
    device_name           = "/dev/sdh"  # Device name (e.g., /dev/sdh)
    encrypted             = true  # Encrypt the volume
    iops                  = 3000  # IOPS for the volume (optional, relevant for io1, io2)
    kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"  # KMS key ID for encryption (optional)
    snapshot_id           = null  # Snapshot ID (optional)
    volume_size           = 100  # Size of the volume in GB
    volume_type           = "gp3"  # Volume type (e.g., gp2, gp3, io1, io2, sc1, st1, standard)
    throughput            = 125  # Throughput for the volume in MB/s (optional, relevant for gp3)
    ebs_block_device_tags                  = { 
      ebs_volume_id = "1"
      ebs-volme_size = "100GB"
      ebs_volume_name    = "EBS-OS-USE-AWLAPPTURBORM02-100"
    }

  }
]
    additional_tags = {
      Role = "VDI-Test-2"
    }
  }
}

#instance_type                = "t2.micro"
#ami = "ami-0a590ca28046d073e"
#instance_count = 2
availability_zone            = "ca-central-1a"
subnet_id                    = ["subnet-0cbab41e10c8cd376", "subnet-0cc714297d4c4eb0d", "subnet-0b9ede96e055876ed"] 

vpc_security_group_ids       = ["sg-077c225984ac0d449"]
#placement_group              = "test"
create_eip                   = false
disable_api_stop             = false
create_iam_instance_profile  = false
iam_instance_profile = "ML-mypoc-ec2-to-s3-access-role"
#iam_role_description         = "IAM role for EC2 instance"
#iam_role_policies            = { "AdministratorAccess" = "arn:aws:iam::aws:policy/AdministratorAccess" }
hibernation                  = true
enclave_options_enabled      = false
user_data_base64             = "IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gVGVycmFmb3JtISIK"
user_data_replace_on_change  = true
launch_template = {
  
}
enable_volume_tags           = true

# root_block_device_encrypted   = true
# root_block_device_volume_type = "gp3"
# root_block_device_throughput  = 200
# root_block_device_volume_size = 50
   

ebs_block_device = [
  {
    delete_on_termination = true  # Delete the volume on instance termination
    device_name           = "/dev/sdh"  # Device name (e.g., /dev/sdh)
    encrypted             = true  # Encrypt the volume
    iops                  = 3000  # IOPS for the volume (optional, relevant for io1, io2)
    kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"  # KMS key ID for encryption (optional)
    snapshot_id           = null  # Snapshot ID (optional)
    volume_size           = 100  # Size of the volume in GB
    volume_type           = "gp3"  # Volume type (e.g., gp2, gp3, io1, io2, sc1, st1, standard)
    throughput            = 125  # Throughput for the volume in MB/s (optional, relevant for gp3)

  }
]



# network_interface = [
#   {
#     device_index         = 0
#     network_interface_id = "eni-89888447"
#     subnet_id            = "subnet-0b9ede96e055876ed"
#     private_ip           = "10.25.5.121"
#     security_groups      = ["sg-05771ad139adffceb"]
#     delete_on_termination = true
#   },
#   {
#     device_index         = 1
#     network_interface_id = "eni-8367797"
#     subnet_id            = "subnet-0b9ede96e055876ed"
#     private_ip           = "10.25.5.120"
#     security_groups      = ["sg-077c225984ac0d449"]
#     delete_on_termination = false
#   }
# ]



vpc_id                     = "vpc-0abb2731619cb0e34"
security_group_name        = "awlapptubormapp01-sg"
security_group_description = "Linux Firewall Access"
ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
]


#log_retention_days = 30
#enable_guardduty = true
#enable_securityhub = true
# ssm_logging_document_content = <<EOT
# {
#   "schemaVersion": "2.2",
#   "description": "Enable logging for SSM",
#   "mainSteps": [
#     {
#       "action": "aws:runCommand",
#       "name": "enableLogging",
#       "inputs": {
#         "DocumentName": "AWS-RunShellScript",
#         "Parameters": {
#           "commands": [
#             "echo 'Logging enabled'"
#           ]
#         }
#       }
#     }
#   ]
# }
# EOT
