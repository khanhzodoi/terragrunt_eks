
locals {
  rds_identifier = "${var.environment}-${var.identifier}"
}

################################################################################
# DB Subnet Group and Security Group
################################################################################
resource "aws_db_subnet_group" "this" {
  name       = "${local.rds_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_security_group" "this" {
  name        = "${local.rds_identifier}-security-group"
  description = "Allow access from eks node group to the RDS database instance"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = var.engine == "mysql" ? 3306 : var.engine == "postgres" ? 5432 : null
    to_port   = var.engine == "mysql" ? 3306 : var.engine == "postgres" ? 5432 : null

    security_groups = [
      var.node_group_security_group_id
    ]
  }

  tags = var.tags
}

################################################################################
# DB Parameter Group
################################################################################

data "aws_rds_engine_version" "family" {
  engine  = var.engine
  version = var.engine_version
}

resource "aws_db_parameter_group" "this" {

  name        = "${local.rds_identifier}-parameter-group"
  description = "RDS parameter groups for ${local.rds_identifier}-parameter-group"
  family      = data.aws_rds_engine_version.family.parameter_group_family

  dynamic "parameter" {
    for_each = var.custom_parameters

    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }

}

################################################################################
# RDS
################################################################################
resource "aws_db_instance" "this" {
  # Database authentication requirements
  identifier = local.rds_identifier
  db_name    = var.database_name
  username   = var.username
  password   = var.password


  # Database technical requirements
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  iops                  = var.storage_type == "io1" ? var.iops : null

  # Database network requirements
  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  multi_az               = try(var.multi_az, false)
  publicly_accessible    = try(var.publicly_accessible, false)
  network_type           = null

  # Database parameter requirements
  parameter_group_name = aws_db_parameter_group.this.id
  option_group_name    = null
  character_set_name   = null
  timezone             = null
  deletion_protection  = try(var.deletion_protection, true)

  # Database maintainance requirements
  allow_major_version_upgrade           = try(var.allow_major_version_upgrade, false)
  auto_minor_version_upgrade            = try(var.auto_minor_version_upgrade, false)
  apply_immediately                     = try(var.apply_immediately, true)
  maintenance_window                    = try(var.maintenance_window, null)
  backup_window                         = try(var.backup_window, "02:00-03:00")
  backup_retention_period               = try(var.backup_retention_period, 7)
  delete_automated_backups              = true
  skip_final_snapshot                   = true
  snapshot_identifier                   = ""
  copy_tags_to_snapshot                 = false
  final_snapshot_identifier             = "final"
  performance_insights_enabled          = false
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = null
  replicate_source_db                   = null
  replica_mode                          = null

  # Database monitoring requirements
  monitoring_interval             = try(var.monitoring_interval, 0)
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring.arn : null
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.this
  ]

}
################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  for_each = toset([for log in var.enabled_cloudwatch_logs_exports : log])

  name              = "/aws/rds/instance/${local.rds_identifier}/${each.value}"
  retention_in_days = 7
  kms_key_id        = null

  tags = var.tags
}

################################################################################
# Enhanced monitoring
################################################################################
data "aws_partition" "current" {}

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  name               = "${local.rds_identifier}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}