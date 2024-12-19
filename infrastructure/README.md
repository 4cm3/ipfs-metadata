# Infrastructure repo

Simple repo to keep track of infra changes for the project.

## Prerequisites

* An IAM user with admin permissions + aws cli access.

## s3 bucket configuration for terraform

Based on this: https://developer.hashicorp.com/terraform/language/backend/s3

* Create a bucket for each env (check infrastructure/dev/ecr/providers.tf to find/change the file name)
* Create the DynamoDB table for keeping locks.

## Deploy infrastructure

You need to go to each of these directories and run `terraform apply` in the same order

* ecr/
* vpc/
* rds/
* ecs/

ECS already includes a task definion with a image stored in SSM. So be sure to run apply code from `ecr/` first and then run a build of https://github.com/4cm3/ipfs-metadata/actions/workflows/build-and-push-container.yml