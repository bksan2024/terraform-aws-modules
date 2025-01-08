
region  = "us-east-1"
profile = "poc-sandbox" #it is for AWS CLI authentication for local validation and not required for Pipelines
###Instance Name Tagging varables###########################################################################
default_tags = {
  "Application" = "Citrix-Test",
  "Environment" = "prod"

}



os_family = "l"
purpose   = "turborm"
additional_tags = {
  Team       = "DevOps"
  CostCenter = "12345"
}
instances = [
  {
    #ami           = "ami-"
    #instance_type = "t2.micro"
    key_name      = "test"
    additional_tags = {
      Project = "VDI-Test-1"
    }
  },
  {
    #ami           = "ami-"
    #instance_type = "t2.medium"
    key_name      = "test"
    additional_tags = {
      Project = "VDI-Test-2"
    }
  }
]
launch_template = [
  {
    id      = "lt-"
    name    = "jenkins"
    version = "1"
  }
]
root_block_device = [
  {
    volume_size           = 50
    volume_type           = "gp3"
    iops                  = 1000
    encrypted             = true
    kms_key_id            = "arn:aws:kms:e"
    throughput            = 125
    delete_on_termination = true
    tags                  = {}
  }
]
ebs_block_device = [
  {
    delete_on_termination = true
    device_name           = "/dev/sdh"
    encrypted             = true
    iops                  = 3000
    kms_key_id            = "arn:aws:kms:"
    snapshot_id           = null
    volume_size           = 10
    volume_type           = "gp3"
    throughput            = 125
    tags = {

    }
  }
]
availability_zone = ""
subnet_id         = ["", ", ""]
enclave_options_enabled = false
user_data_base64             = "IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gVGVycmFmb3JtISIK"
