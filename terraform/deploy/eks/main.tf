provider "aws" {
  region = var.aws_region
  # If using a named profile, uncomment the next line
  # profile = "your-profile-name"
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  cluster_name      = "test-cluster"
  env               = var.env
  aws_region        = var.aws_region
  thumbprint_list   = var.thumbprint_list
  aws_addon_registry = var.aws_addon_registry
  
  # Node configuration - System nodes
  system_nodes_desired_size = var.system_nodes_desired_size
  system_nodes_max_size     = var.system_nodes_max_size
  system_nodes_min_size     = var.system_nodes_min_size
  system_node_instance_type = var.system_node_instance_type
  
  # Node configuration - Application nodes
  app_nodes_desired_size = var.app_nodes_desired_size
  app_nodes_max_size     = var.app_nodes_max_size
  app_nodes_min_size     = var.app_nodes_min_size
  app_node_instance_type = var.app_node_instance_type
  
  # Networking
  vpc_cidr           = var.vpc_cidr
  enable_public_access = var.enable_public_access
  
  # Add-ons
  alb_controller_version = var.alb_controller_version
  
  # Tagging
  finops_tags = var.finops_tags
}