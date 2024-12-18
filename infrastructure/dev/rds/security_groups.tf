module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 5.0"

  name                = local.name
  description         = "rds-${local.name}-security-group"
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_cidr_blocks = data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks

  tags = local.tags
}
