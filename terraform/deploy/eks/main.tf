provider "aws" {
  region = var.aws_region
  profile = "test-user"
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  cluster_name      = "infra-cluster"
  env               = var.env
  aws_region        = var.aws_region
  thumbprint_list   = var.thumbprint_list
  aws_addon_registry = var.aws_addon_registry
  
  # Node configuration
  nodes_desired_size = var.nodes_desired_size
  nodes_max_size     = var.nodes_max_size
  nodes_min_size     = var.nodes_min_size
  node_instance_type = var.node_instance_type
  
  # Networking
  vpc_cidr           = var.vpc_cidr
  enable_public_access = var.enable_public_access
  
  # Add-ons
  alb_controller_version = var.alb_controller_version
  
  # Tagging
  finops_tags = var.finops_tags
}