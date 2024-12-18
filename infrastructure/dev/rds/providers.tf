terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region         = "us-west-2"
    bucket         = "ipfs-tfstate-bon4ca"
    key            = "dev/rds/terraform.tfstate"
    dynamodb_table = "ipfs-tf-tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Application = "ipfs-metadata"
      Environment = "dev"
    }
  }
}
