
variable "environment" {
  description = "The environment does this resource belong to? - dev, staging, production"
  type        = string

  validation {
    condition     = can(regex("(^dev$)|(^staging$)|(^production$)", var.environment))
    error_message = "The environment value should be one of - dev, staging, production."
  }
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  nullable    = false
  default     = ""
}

variable "cluster_version" {
  description = "Desired K8S master version"
  type        = string
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "subnet_ids" {
  type     = list(string)
  nullable = false
  default  = []
}

variable "cluster_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes"
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes"
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  type     = map(any)
  nullable = false
  default = {
    default-node-group = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      disk_size = 50
    }
  }
}

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "tags" {
  type     = map(any)
  nullable = false
  default = {
    "Application" = "default-gitops-infrastructure",
    "CreatedBy"   = "terraform",
    "Environment" = "default",
    "Repository"  = "github.com/serverless-delivery/serverless-gitops-infrastructure"
  }
}