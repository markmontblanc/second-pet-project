

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-integrated"

  # Capacity Providers
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
        base   = 2
      }
    }
  }

  services = {
    rds = {
      cpu    = 1024
      memory = 4096

      container_definitions = {
        rds = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "654654200977.dkr.ecr.eu-north-1.amazonaws.com/petp_rds_repo_default:latest"
          port_mappings = [
            {
              name          = "rds"
              containerPort = 8001
              protocol      = "tcp"
            }
          ]

          environment = [
            {
              name  = "DB_HOST"
              value = "my-petp-db-default.ctsskiqw2d3n.eu-north-1.rds.amazonaws.com"
            },
            {
              name  = "DB_PORT"
              value = "5432"
            },
            {
              name  = "DB_NAME"
              value = "marko_db"
            },
            {
              name  = "DB_USER"
              value = "postgres"
            },
            {
              name  = "DB_PASSWORD"
              value = "adminadmin76!"
            }
          ]
        }
      }


      subnet_ids = module.vpc.private_subnets
      security_group_ids = [aws_security_group.rds_sg.id]
    }

    redis = {
      cpu    = 1024
      memory = 4096

      container_definitions = {
        redis = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "654654200977.dkr.ecr.eu-north-1.amazonaws.com/petp_redis_repo_default:latest"
          port_mappings = [
            {
              name          = "redis"
              containerPort = 8002
              protocol      = "tcp"
            }
          ]

          environment = [
            {
              name  = "REDIS_HOST"
              value = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address
            },
            {
              name  = "REDIS_PORT"
              value = "6379"
            },
            {
              name  = "REDIS_DB"
              value = "0"
            }
          ]
        }
      }

      subnet_ids = module.vpc.private_subnets
      security_group_ids = [aws_security_group.redis_sg.id]
    }
  }

  tags = {
    Environment = "Development"
  }
}


#Security groups for services
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port                = 8001
    to_port                  = 8001
    protocol                 = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Security group for Redis service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port                = 8002
    to_port                  = 8002
    protocol                 = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis_sg"
  }
}

