resource "aws_iam_role" "eks" {
  name        = "${var.environment}-${var.cluster_name}-eks-cluster"
  description = "IAM role for ${var.environment}-${var.cluster_name} eks cluster"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

}

resource "aws_iam_role_policy_attachment" "eks" {
  for_each = var.cluster_iam_policies

  policy_arn = each.value
  role       = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "this" {
  name     = "${var.environment}-${var.cluster_name}"
  version  = var.cluster_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    # security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.subnet_ids
  }

  tags = var.tags
  depends_on = [
    aws_iam_role_policy_attachment.eks
  ]
}
