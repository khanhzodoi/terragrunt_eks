terraform {
  source = "../../../infrastructure-modules/kubernetes-addons"
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
  tags                = dependency.tags.outputs.tags
  cluster_name        = dependency.eks.outputs.cluster_name
  aws_region          = include.env.locals.aws_region
  openid_provider_arn = dependency.eks.outputs.openid_provider_arn

  enable_cluster_autoscaler      = true
  cluster_autoscaler_helm_verion = "9.28.0"


  enable_storage_ebs_csi                = true
  enable_storage_ebs_csi_kms_encryption = true
  storage_ebs_csi_helm_verion           = "2.24.0"

}



dependency "eks" {
  config_path = "../eks"


  mock_outputs = {
    eks_security_group_id = "sg-xxxxxxxxxxxxxxxxx"
    cluster_name          = "eks-mock"
    openid_provider_arn   = "arn:aws:iam::xxxx:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/xxxxxx"
  }
}

generate "helm_provider" {
  path      = "helm-provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF

data "aws_eks_cluster" "eks" {
    name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.cluster_name
}

provider "helm" {
    kubernetes {
        host    = data.aws_eks_cluster.eks.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
        exec {
            api_version = "client.authentication.k8s.io/v1beta1"
            args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name, "--profile", "khanhp-iam"]
            command     = "aws"
        }
    }
}
EOF
}

dependency "tags" {
  config_path = "../tags"

  mock_outputs = {
    tags = {
      "Application" = "demo-mock"
      "CreatedBy"   = "terraform"
      "DeployedBy"  = "arn:aws:iam::123456789123:user/khanhpham"
      "Environment" = "mock"
      "Name"        = "/aws/eks/demo-mock/cluster"
      "Repository"  = "https://github.com/clowdhaus/eks-reference-architecture"
    }
  }
}