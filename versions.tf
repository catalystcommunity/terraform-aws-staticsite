terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
      configuration_aliases = [
        aws.main,
        aws.acm, # must be in us-east-1, required for ACM certificates
      ]
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
