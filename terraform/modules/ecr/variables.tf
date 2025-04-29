variable "tags" {
  description = "Tags to apply to ECR resources"
  type        = map(string)
  default     = {}
}

variable "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role that needs pull access to ECR"
  type        = string
  default     = ""  # Made optional with empty default
}