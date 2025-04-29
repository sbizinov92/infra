# IMPORTANT: Free-tier optimized configuration
# Note that while this configuration aims to use free tier resources where possible,
# some AWS services like EKS, NAT Gateway, and EIPs have costs even at minimal usage.
# This configuration minimizes costs but will not be entirely free.

# AWS region
aws_region = "eu-west-1"

# Environment
env = "dev"

# OIDC thumbprints for the EKS cluster
thumbprint_list = [
  "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" # Example thumbprint
]

# AWS addon registry
aws_addon_registry = "602401143452.dkr.ecr.eu-west-1.amazonaws.com"

# System nodes configuration
system_nodes_desired_size = 3  
system_nodes_max_size     = 3
system_nodes_min_size     = 2
system_node_instance_type = ["t3.small"]  
# Application nodes configuration
app_nodes_desired_size = 1  
app_nodes_max_size     = 2
app_nodes_min_size     = 1
app_node_instance_type = ["t3.small"]  

# Networking
vpc_cidr = "10.0.0.0/16"
enable_public_access = true

# Add-ons
alb_controller_version = "1.4.8"

# FinOps tags
finops_tags = {
  "product:devops" = "true"
  "product:shared" = "false"
  "cost_center"    = "hosting"
  "owner"          = "devops"
}