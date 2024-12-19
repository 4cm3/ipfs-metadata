locals {
  name   = "ipfs-metadata-${local.env}"
  region = "us-west-2"
  env    = "dev"

  container_name = "ipfs-metadata"
  container_port = 8080

  tags = {
    Application = "ipfs-metadata"
    Environment = local.env
  }
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name             = local.name
  cluster_arn      = module.ecs_cluster.cluster_arn
  subnet_ids       = data.terraform_remote_state.vpc.outputs.public_subnets
  assign_public_ip = true

  cpu    = 1024
  memory = 4096

  container_definitions = {

    (local.container_name) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = data.aws_ssm_parameter.ecr_image.value
      environment = [
        {
          name  = "POSTGRES_USER"
          value = "complete_postgresql"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["password"]
        },
        {
          name  = "POSTGRES_DB"
          value = "completePostgresql"
        },
        {
          name  = "POSTGRES_HOST"
          value = data.terraform_remote_state.rds.outputs.db_instance_address
        },
        {
          name  = "POSTGRES_PORT"
          value = "5432"
        },
      ]
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      memory_reservation = 100
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ipfs_metadata"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ignore_task_definition_changes = false
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    region = "us-west-2"
    bucket = "ipfs-tfstate-bon4ca"
    key    = "${local.env}/ecr/terraform.tfstate"
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

data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    region = "us-west-2"
    bucket = "ipfs-tfstate-bon4ca"
    key    = "${local.env}/rds/terraform.tfstate"
  }
}

data "aws_secretsmanager_secret" "rds_password" {
  arn = data.terraform_remote_state.rds.outputs.db_instance_master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.rds_password.id
}

data "aws_ssm_parameter" "ecr_image" {
  name = data.terraform_remote_state.ecr.outputs.aws_ssm_parameter
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}
