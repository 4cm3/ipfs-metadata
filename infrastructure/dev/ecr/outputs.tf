output "repository_name" {
  value = module.ecr.repository_name
}

output "repository_arn" {
  value = module.ecr.repository_arn
}

output "repository_url" {
  value = module.ecr.repository_url
}

output "aws_ssm_parameter" {
  value = resource.aws_ssm_parameter.ecr_image.name
}
