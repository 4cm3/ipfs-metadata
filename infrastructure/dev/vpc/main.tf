locals {
  name   = "ipfs-metadata-${local.env}"
  region = "us-west-2"
  env    = "dev"

  vpc_cidr = "10.1.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint   = local.name
    GithubRepo  = "github.com/aws-ia/terraform-aws-eks-blueprints"
    Application = "ipfs-metadata"
    Environment = local.env
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + length(local.azs))]

  tags = local.tags
}
