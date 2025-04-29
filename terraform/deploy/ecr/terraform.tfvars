# AWS region
aws_region = "eu-west-1"

# The EKS node role ARN can be filled in after EKS deployment
# Leave empty for now, and the repository policy will not be created
eks_node_role_arn = ""

# Tags
tags = {
  "environment"   = "dev"
  "managed-by"    = "terraform"
  "product:devops" = "true"
  "product:shared" = "false"
  "cost_center"    = "hosting"
  "owner"          = "devops"
}