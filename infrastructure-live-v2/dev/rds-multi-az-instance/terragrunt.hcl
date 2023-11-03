terraform {
  source = "../../../infrastructure-modules/rds-db-instance"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}


inputs = {
  # Database authentication requirements
  identifier    = include.env.locals.rds_identifier
  database_name = include.env.locals.rds_database_name
  username      = include.env.locals.rds_username
  password      = include.env.locals.rds_password

  # Database technical requirements
  engine                = "mysql"
  engine_version        = "5.7.39"
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  max_allocated_storage = 200
  storage_type          = "gp2"
  iops                  = null

  # Database network requirements
  vpc_id              = dependency.vpc.outputs.vpc_id
  multi_az            = true
  publicly_accessible = false
  subnet_ids          = dependency.vpc.outputs.private_subnet_ids

  # Database network security
  node_group_security_group_id = dependency.eks.outputs.eks_security_group_id

  # Database parameter requirements
  custom_parameters   = []
  deletion_protection = true

  # Database maintainance requirements
  allow_major_version_upgrade           = false
  auto_minor_version_upgrade            = true
  apply_immediately                     = true
  maintenance_window                    = "Thu:04:00-Thu:05:00"
  backup_window                         = "23:45-01:30"
  backup_retention_period               = 7
  performance_insights_enabled          = false
  performance_insights_retention_period = 7


  # Database monitoring requirements
  monitoring_interval             = 60
  deletion_protection             = false
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery", "general"]

  environment = include.env.locals.environment
  tags        = dependency.tags.outputs.tags

}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    eks_security_group_id = "sg-xxxxxxxxxxxxxxxxx"
    cluster_name          = "eks-mock"
    openid_provider_arn   = "arn:aws:iam::xxxx:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/xxxxxx"
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
    vpc_id             = "vpc-mock"
  }
}


dependency "tags" {
  config_path = "../tags"

  mock_outputs = {
    tags = {
      "Application" = "demo-mock"
      "CreatedBy"   = "terraform"
      "DeployedBy"  = "arn:aws:iam::123456789123:user/khanhpham"
      "Environment" = "default"
      "Repository"  = "github.com/khanhzodoi"
    }
  }
}
