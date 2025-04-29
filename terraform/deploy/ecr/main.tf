provider "aws" {
  region = var.aws_region
  profile = "test-user"
}

module "ecr" {
  source = "../../modules/ecr"
  
  # Pass the EKS node role ARN to allow ECR pull access
  eks_node_role_arn = var.eks_node_role_arn
  
  # Use the same tags as other resources
  tags = var.tags
}