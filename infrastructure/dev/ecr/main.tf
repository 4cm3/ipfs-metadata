locals {
  service = "ipfs-metadata"
  env     = "dev"
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${local.service}-${local.env}"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 5 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform = "true"
    env       = local.env
  }
}

resource "aws_ssm_parameter" "ecr_image" {
  name  = "/ipfs/${local.env}/ecr_image"
  type  = "SecureString"
  value = "CHANGEME"

  lifecycle {
    ignore_changes = [value]
  }
}
