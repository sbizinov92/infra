variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster."
}

variable "nodes_desired_size" {
  type = number
  default = 2
  description = "Desired number of worker nodes in the EKS cluster."
}

variable "nodes_max_size" {
  type = number
  default = 3
  description = "Maximum number of worker nodes in the EKS cluster."
}

variable "nodes_min_size" {
  type = number
  default = 1
  description = "Minimum number of worker nodes in the EKS cluster."
}

variable "node_instance_type" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "List of instance types for worker nodes in the EKS cluster."
}

# variable "argocd_version" {
#   type        = string
#   default     = "7.7.13"
#   description = "ArgoCD version to deploy."
# }

variable "thumbprint_list" {
  type        = list(string)
  description = "List of thumbprints for the EKS cluster."
}

variable "env" {
  type        = string
  description = "Environment name."
}

variable "aws_region" {
  type        = string
  description = "AWS region."
}

variable "aws_addon_registry" {
  type        = string
  description = "ECR registry for addons."
}

variable "finops_tags" {
  type        = map(string)
  description = "Tags for finops."
}

variable "alb_controller_version" {
  type        = string
  default     = "1.4.8"
  description = "AWS Load Balancer Controller Helm chart version."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC."
}

variable "enable_public_access" {
  type        = bool
  default     = true
  description = "Whether to enable public access to the EKS cluster."
}