variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role that needs pull access to ECR"
  type        = string
  default     = ""  
}

variable "tags" {
  description = "Tags to apply to ECR resources"
  type        = map(string)
  default     = {
    "environment" = "dev"
    "managed-by"  = "terraform"
  }
}