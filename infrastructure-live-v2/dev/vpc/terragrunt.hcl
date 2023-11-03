terraform {
  source = "../../../infrastructure-modules/vpc"
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
  vpc_cidr_block  = include.env.locals.vpc_cidr_block
  azs             = include.env.locals.azs
  private_subnets = include.env.locals.private_subnets
  public_subnets  = include.env.locals.public_subnets

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                                                     = 1
    "kubernetes.io/cluster/${include.env.locals.environment}-${include.env.locals.cluster_name}" = "owned"

  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                                            = 1
    "kubernetes.io/cluster/${include.env.locals.environment}-${include.env.locals.cluster_name}" = "owned"
  }

  tags = dependency.tags.outputs.tags


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