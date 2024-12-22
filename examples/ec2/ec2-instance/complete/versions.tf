terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = var.default_tags
  }
}
/*
provider "aws" {
  alias   = "secondary"
  region  = var.secondary_region
  profile = var.secondary_profile
  default_tags {
    tags = var.default_tags
  }
}
*/