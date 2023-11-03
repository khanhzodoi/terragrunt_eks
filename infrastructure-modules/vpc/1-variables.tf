
variable "environment" {
  description = "Environment"
  type        = string
  nullable    = false
  default     = "default"
}


variable "tags" {
  description = "Tags"
  nullable    = false
  type        = map(any)
  default = {
    "Application" = "default-gitops-infrastructure",
    "CreatedBy"   = "terraform",
    "Environment" = "default",
    "Repository"  = "github.com/serverless-delivery/serverless-gitops-infrastructure"
  }
}

variable "vpc_cidr_block" {
  type     = string
  nullable = false
  default  = "10.0.0.0/16"
}

variable "private_subnets" {
  type     = list(string)
  nullable = false
}

variable "public_subnets" {
  type     = list(string)
  nullable = false
}

variable "azs" {
  type     = list(string)
  nullable = false
}


variable "public_subnet_tags" {
  type = map(any)
  default = {
    "kubernetes.io/role/elb" = 1
  }
}

variable "private_subnet_tags" {
  type = map(any)
  default = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
