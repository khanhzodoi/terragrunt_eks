variable "tags" {
  description = "Environment name."
  type        = map(any)
}

variable "aws_region" {
  description = "Region name for auto scaler to find resources properly."
  type        = string
  nullable    = true
}

variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
}

variable "enable_cluster_autoscaler" {
  description = "Determines whether to use cluster autoscaler"
  type        = bool
  default     = false
}

variable "enable_storage_ebs_csi" {
  description = "Determines whether to use storage ebs csi"
  type        = bool
  default     = false
}

variable "enable_storage_ebs_csi_kms_encryption" {
  description = "Determines whether to use storage ebs csi"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_helm_verion" {
  description = "Cluster Autoscaler Helm verion"
  type        = string
}

variable "storage_ebs_csi_helm_verion" {
  description = "Storage EBS CSI Helm verion"
  type        = string
}

variable "openid_provider_arn" {
  description = "IAM Openid Connect Provider ARN"
  type        = string
}