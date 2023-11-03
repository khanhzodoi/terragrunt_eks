data "aws_iam_policy_document" "storage_ebs_csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "storage_ebs_csi" {
  count = var.enable_storage_ebs_csi ? 1 : 0

  name               = "${var.cluster_name}-ebs-csi-controller-sa"
  assume_role_policy = data.aws_iam_policy_document.storage_ebs_csi.json
  tags               = var.tags
}


resource "aws_iam_policy" "storage_ebs_csi_kms_encryption" {
  count = var.enable_storage_ebs_csi_kms_encryption ? 1 : 0

  name = "${var.cluster_name}-storage-ebs-csi-kms-encryption"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlainText",
          "kms:CreateGrant"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "storage_ebs_csi" {
  # Define the map inline here
  for_each = var.enable_storage_ebs_csi && var.enable_storage_ebs_csi_kms_encryption ? {
    1 = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    2 = aws_iam_policy.storage_ebs_csi_kms_encryption[0].arn
    } : {
    1 = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  role       = aws_iam_role.storage_ebs_csi[0].name
  policy_arn = each.value

}

resource "helm_release" "storage_ebs_csi" {
  # Ref link: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
  count = var.enable_storage_ebs_csi ? 1 : 0

  name = "aws-ebs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = var.storage_ebs_csi_helm_verion

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.storage_ebs_csi[0].arn
  }

  set {
    name  = "controller.region"
    value = var.aws_region
  }

  depends_on = [aws_iam_role.storage_ebs_csi]
}