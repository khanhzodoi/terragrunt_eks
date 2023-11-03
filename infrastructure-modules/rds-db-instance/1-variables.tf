variable "tags" {
  description = "Environment name."
  type        = map(any)
}

variable "environment" {
  description = "Environment"
  type        = string
  nullable    = false
}

variable "identifier" {
  type     = string
  nullable = false
}

variable "database_name" {
  type     = string
  nullable = false
}

variable "username" {
  type     = string
  nullable = false
}

variable "password" {
  type     = string
  nullable = false
}

variable "engine" {
  type     = string
  nullable = false

  validation {
    condition     = can(regex("(^mysql$)|(^postgres$)", var.engine))
    error_message = "The egine value should be one of - mysql, postgres."
  }
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "engine_version" {
  type     = string
  nullable = false
}

variable "instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 100
    error_message = "allocated_storage must be at least 20 GB and not greater than 100 GB."
  }
}

variable "max_allocated_storage" {
  type    = number
  default = 200

  validation {
    condition     = var.max_allocated_storage <= 10240
    error_message = "max_allocated_storage must be not greater than 10 TB (10240 GB)."
  }
}

variable "storage_type" {
  type    = string
  default = "io1"
}

variable "iops" {
  type        = number
  nullable    = true
  description = "The IOPS for the RDS instance"
  default = null

}

variable "node_group_security_group_id" {
  type    = string
  default = "sg-xxxxxxxxxxxxxxxxx"
}

variable "monitoring_role_name_prefix" {
  type    = string
  default = ""
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "allow_major_version_upgrade" {
  type    = bool
  default = false
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "maintenance_window" {
  type    = string
  default = "Thu:04:00-Thu:05:00"
}

variable "backup_window" {
  type    = string
  default = "02:00-03:00"
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "monitoring_interval" {
  type    = number
  default = 60
}

variable "performance_insights_enabled" {
  description = "The repository name where this resource is managed and codified"
  nullable    = true
  type        = bool
  default     = false

}

variable "performance_insights_retention_period" {
  description = "The repository name where this resource is managed and codified"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = ["audit", "error", "slowquery", "general"]
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-123", "subnet-456"]
}

variable "custom_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
