output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "openid_provider_arn" {
  value = aws_iam_openid_connect_provider.this[0].arn
}


output "eks_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}