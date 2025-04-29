# Create OIDC provider for the EKS cluster
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  # Using a more reliable method to get the thumbprint
  thumbprint_list = var.thumbprint_list
  url             = aws_eks_cluster.infra-cluster.identity[0].oidc[0].issuer

  tags = merge(
    var.finops_tags,
    {
      Name = "${var.cluster_name}-eks-oidc-provider"
    }
  )

  depends_on = [aws_eks_cluster.infra-cluster]
}

# Fetch the OIDC issuer URL without the https:// prefix for use in IAM roles
locals {
  eks_oidc_issuer_url = replace(aws_eks_cluster.infra-cluster.identity[0].oidc[0].issuer, "https://", "")
}