output "db_instance_master_user_secret_arn" {
  value = module.rds.db_instance_master_user_secret_arn
}

output "db_instance_address" {
  description = "The ID of the VPC"
  value       = module.rds.db_instance_address
}

