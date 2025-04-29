data "aws_eks_cluster" "infra-cluster" {
  name = aws_eks_cluster.infra-cluster.name

  depends_on = [
    aws_eks_cluster.infra-cluster
  ]
}

data "aws_eks_cluster_auth" "infra-cluster" {
  name = aws_eks_cluster.infra-cluster.name

  depends_on = [
    aws_eks_cluster.infra-cluster
  ]
}

data "aws_caller_identity" "this" {}