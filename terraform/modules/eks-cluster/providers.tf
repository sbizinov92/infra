terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.infra-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.infra-cluster.certificate_authority[0].data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.infra-cluster.name
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.infra-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.infra-cluster.certificate_authority[0].data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.infra-cluster.name
      ]
    }
  }
}