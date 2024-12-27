package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Initialize Terraform options
func getTerraformOptions(terraformDir string) *terraform.Options {
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"name":          "enterprise-ec2-instance",
			"instance_type": "t2.micro",
			"region":        "us-east-1",
		},
	}
}

// Test Block 1: Basic Resource Validation
func TestBasicResourceValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 1.1: Instance Creation
	instanceID := terraform.Output(t, terraformOptions, "instance_id")
	assert.NotEmpty(t, instanceID, "Expected instance_id to be non-empty")

	publicIP := terraform.Output(t, terraformOptions, "public_ip")
	assert.NotEmpty(t, publicIP, "Expected public_ip to be non-empty")

	// Test Case 1.2: Instance Configuration
	instanceType := terraform.Output(t, terraformOptions, "instance_type")
	assert.Equal(t, "t2.micro", instanceType, "Expected instance_type to be t2.micro")

	amiID := terraform.Output(t, terraformOptions, "ami_id")
	assert.Contains(t, amiID, "ami-", "Expected ami_id to match the correct format")

	// Test Case 1.3: Instance Tags
	tags := terraform.OutputMap(t, terraformOptions, "tags")
	assert.Equal(t, "enterprise-ec2-instance", tags["Name"], "Expected Name tag to be enterprise-ec2-instance")
	assert.Equal(t, "Production", tags["Environment"], "Expected Environment tag to be Production")
	assert.Equal(t, "12345", tags["CostCenter"], "Expected CostCenter tag to be 12345")
	assert.Equal(t, "JohnDoe", tags["Owner"], "Expected Owner tag to be JohnDoe")
}

// Test Block 2: Security and Compliance
func TestSecurityAndCompliance(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 2.1: Security Group Rules
	securityGroupIngressRules := terraform.OutputListOfObjects(t, terraformOptions, "security_group_ingress_rules")
	assert.NotNil(t, securityGroupIngressRules, "Expected ingress rules to be non-empty")
	assert.Contains(t, securityGroupIngressRules, map[string]interface{}{"protocol": "tcp", "from_port": 22, "cidr_blocks": []string{"0.0.0.0/0"}}, "Expected ingress rule for SSH on port 22")

	securityGroupEgressRules := terraform.OutputListOfObjects(t, terraformOptions, "security_group_egress_rules")
	assert.Contains(t, securityGroupEgressRules, map[string]interface{}{"protocol": "-1", "cidr_blocks": []string{"0.0.0.0/0"}}, "Expected egress rule to allow all traffic")

	// Test Case 2.2: IAM Role and Policies
	iamRoleName := terraform.Output(t, terraformOptions, "iam_role_name")
	assert.NotEmpty(t, iamRoleName, "Expected IAM role to be attached to the EC2 instance")

	iamPolicies := terraform.OutputList(t, terraformOptions, "iam_policies")
	assert.Contains(t, iamPolicies, "AmazonSSMManagedInstanceCore", "Expected IAM role to include AmazonSSMManagedInstanceCore policy")
}

// Test Block 3: Networking
func TestNetworking(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 3.1: VPC and Subnet Configuration
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	assert.Equal(t, "vpc-123abc", vpcID, "Expected instance to be in the correct VPC")

	subnetCIDRBlocks := terraform.OutputList(t, terraformOptions, "subnet_cidr_blocks")
	assert.Contains(t, subnetCIDRBlocks, "10.0.1.0/24", "Expected instance to be in the private subnet 10.0.1.0/24")

	// Test Case 3.2: Elastic IPs
	publicIP := terraform.Output(t, terraformOptions, "public_ip")
	assert.Empty(t, publicIP, "Expected instance to not have a public IP")
}

// Test Block 4: Storage and Volumes
func TestStorageAndVolumes(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 4.1: Root Volume Configuration
	rootVolumeSize := terraform.Output(t, terraformOptions, "root_volume_size")
	assert.Equal(t, "8", rootVolumeSize, "Expected root volume size to be 8 GB")

	rootVolumeType := terraform.Output(t, terraformOptions, "root_volume_type")
	assert.Equal(t, "gp3", rootVolumeType, "Expected root volume type to be gp3")
}
// Test Block 5: Monitoring and Logging
func TestMonitoringAndLogging(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 5.1: Monitoring
	detailedMonitoring := terraform.Output(t, terraformOptions, "detailed_monitoring")
	assert.Equal(t, "true", detailedMonitoring, "Expected detailed monitoring to be enabled")

	// Test Case 5.2: CloudWatch Logging
	cloudWatchLogsForwarding := terraform.Output(t, terraformOptions, "cloudwatch_logs_forwarding")
	assert.Equal(t, "true", cloudWatchLogsForwarding, "Expected system logs to be forwarded to CloudWatch Logs")

	logRetentionDays := terraform.Output(t, terraformOptions, "cloudwatch_log_group_retention_days")
	assert.Equal(t, "30", logRetentionDays, "Expected CloudWatch log group retention to be 30 days")
}

// Test Block 6: Fault Tolerance and Availability
func TestFaultToleranceAndAvailability(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	#// Test Case 6.1: Multi-AZ Deployment
	availabilityZones := terraform.OutputList(t, terraformOptions, "availability_zones")
	assert.Greater(t, len(availabilityZones), 1, "Expected deployment across multiple availability zones")

	// Test Case 6.2: Termination Protection
	terminationProtection := terraform.Output(t, terraformOptions, "termination_protection")
	assert.Equal(t, "true", terminationProtection, "Expected termination protection to be enabled")

	// Test Case 6.3: Auto-Recovery
	autoRecoveryEnabled := terraform.Output(t, terraformOptions, "auto_recovery_enabled")
	assert.Equal(t, "true", autoRecoveryEnabled, "Expected auto-recovery to be enabled for the instance")
}

// Test Block 7: Cost Optimization
func TestCostOptimization(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 7.1: Instance Type
	instanceType := terraform.Output(t, terraformOptions, "instance_type")
	assert.Equal(t, "t3.medium", instanceType, "Expected instance type to be t3.medium for cost optimization")

	// Test Case 7.2: Spot Instances
	spotInstanceEnabled := terraform.Output(t, terraformOptions, "spot_instance_enabled")
	assert.Equal(t, "true", spotInstanceEnabled, "Expected spot instance to be used for non-critical workloads")

	spotFallback := terraform.Output(t, terraformOptions, "spot_fallback")
	assert.Equal(t, "true", spotFallback, "Expected spot instance to have a fallback configuration")

	// Test Case 7.3: Unused Resources
	unattachedVolumesCount := terraform.Output(t, terraformOptions, "unattached_volumes_count")
	assert.Equal(t, "0", unattachedVolumesCount, "Expected no unattached volumes")

	idleInstancesCount := terraform.Output(t, terraformOptions, "idle_instances_count")
	assert.Equal(t, "0", idleInstancesCount, "Expected no idle instances")
}

// Test Block 8: Runtime Validation
func TestRuntimeValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 8.1: SSH Connectivity
	sshAccessible := terraform.Output(t, terraformOptions, "ssh_accessible")
	assert.Equal(t, "true", sshAccessible, "Expected SSH to be accessible for allowed IP ranges")

	// Test Case 8.2: Application Deployment
	applicationStatus := terraform.Output(t, terraformOptions, "application_status")
	assert.Equal(t, "running", applicationStatus, "Expected application to be running on the instance")

	// Test Case 8.3: Remote Command Execution
	commandOutput := terraform.Output(t, terraformOptions, "command_output")
	assert.Equal(t, "Hello, World!", commandOutput, "Expected command output to match 'Hello, World!'")
}

// Test Block 9: Compliance
func TestCompliance(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions("../")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test Case 9.1: CIS Benchmarks
	cisCompliancePassed := terraform.Output(t, terraformOptions, "cis_compliance_passed")
	assert.Equal(t, "true", cisCompliancePassed, "Expected instance to pass CIS compliance checks")

	// Test Case 9.2: PCI DSS Compliance
	pciDssCompliancePassed := terraform.Output(t, terraformOptions, "pci_dss_compliance_passed")
	assert.Equal(t, "true", pciDssCompliancePassed, "Expected instance to pass PCI DSS compliance checks")

	// Test Case 9.3: GDPR and Data Residency
	gdprCompliancePassed := terraform.Output(t, terraformOptions, "gdpr_compliance_passed")
	assert.Equal(t, "true", gdprCompliancePassed, "Expected instance to comply with GDPR regulations")

	dataRegion := terraform.Output(t, terraformOptions, "data_region")
	assert.Equal(t, "eu-west-1", dataRegion, "Expected data residency to be in eu-west-1")
}
