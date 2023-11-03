terraform {
  source = "../../../infrastructure-modules/eks"
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
  environment     = include.env.locals.environment
  cluster_name    = include.env.locals.cluster_name
  cluster_version = include.env.locals.cluster_version
  subnet_ids      = dependency.vpc.outputs.private_subnet_ids
  vpc_id          = dependency.vpc.outputs.vpc_id

  tags = dependency.tags.outputs.tags

  node_groups = {
    general = {
      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      scaling_config = {
        desired_size = 1
        max_size     = 10
        min_size     = 0
      }

    }
  }

  // node_iam_policies = {
  //     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  // }

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
