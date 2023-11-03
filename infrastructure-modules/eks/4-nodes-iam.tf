resource "aws_iam_role" "nodes" {
  name        = "${var.environment}-${var.cluster_name}-eks-node-group"
  description = "IAM role for ${var.environment}-${var.cluster_name} eks node groups"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes" {
  for_each = var.node_iam_policies

  policy_arn = each.value
  role       = aws_iam_role.nodes.name
}

