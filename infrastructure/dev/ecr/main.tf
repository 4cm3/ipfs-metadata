locals {
  service     = "ipfs-metadata"
  environment = "dev"
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                 = "${local.service}-${local.environment}"
  repository_image_tag_mutability = "MUTABLE"
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
    Terraform   = "true"
    Environment = local.environment
  }
}
