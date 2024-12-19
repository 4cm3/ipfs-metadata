locals {
  name   = "ipfs-metadata"
  region = "us-west-2"
  env    = "dev"

  tags = {
    Application = local.name
    Environment = local.env
    GithubRepo  = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "us-west-2"
    bucket = "ipfs-tfstate-bon4ca"
    key    = "${local.env}/vpc/terraform.tfstate"
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier                     = "${local.name}-${local.env}"
  instance_use_identifier_prefix = true

  parameters = [
    {
      name  = "rds.force_ssl"
      value = "0"
    },
  ]

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.micro"

  allocated_storage = 20

  db_name  = "completePostgresql"
  username = "complete_postgresql"
  port     = 5432

  subnet_ids                  = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_security_group_ids      = [module.rds_security_group.security_group_id]
  manage_master_user_password = true
  create_db_subnet_group      = true

  tags = local.tags
}
