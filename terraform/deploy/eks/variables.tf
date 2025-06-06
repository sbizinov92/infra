variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "thumbprint_list" {
  description = "List of server certificate thumbprints for OIDC identity provider"
  type        = list(string)
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_addon_registry" {
  description = "AWS addon registry URL"
  type        = string
  default     = "602401143452.dkr.ecr.eu-west-1.amazonaws.com"
}

# System node group variables
variable "system_nodes_desired_size" {
  type        = number
  default     = 2
  description = "Desired number of system worker nodes in the EKS cluster."
}

variable "system_nodes_max_size" {
  type        = number
  default     = 3
  description = "Maximum number of system worker nodes in the EKS cluster."
}

variable "system_nodes_min_size" {
  type        = number
  default     = 2
  description = "Minimum number of system worker nodes in the EKS cluster."
}

variable "system_node_instance_type" {
  type        = list(string)
  default     = ["t3.micro"]
  description = "List of instance types for system worker nodes in the EKS cluster."
}

# Application node group variables
variable "app_nodes_desired_size" {
  type        = number
  default     = 1
  description = "Desired number of application worker nodes in the EKS cluster."
}

variable "app_nodes_max_size" {
  type        = number
  default     = 2
  description = "Maximum number of application worker nodes in the EKS cluster."
}

variable "app_nodes_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of application worker nodes in the EKS cluster."
}

variable "app_node_instance_type" {
  type        = list(string)
  default     = ["t3.micro"]
  description = "List of instance types for application worker nodes in the EKS cluster."
}

variable "finops_tags" {
  description = "Tags for financial operations and resource attribution"
  type        = map(string)
  default = {
    "product:devops" = "true"
    "product:shared" = "false"
    "cost_center"    = "hosting"
    "owner"          = "devops"
  }
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

variable "alb_controller_version" {
  type        = string
  default     = "1.4.8"
  description = "AWS Load Balancer Controller Helm chart version."
}