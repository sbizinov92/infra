# Create a EKS cluster 
resource "aws_eks_cluster" "infra-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.infra-cluster.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.private[*].id,
      aws_subnet.public[*].id
    )
    endpoint_private_access = true
    endpoint_public_access  = true  # Ensure public access is enabled
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Only encrypt secrets with KMS key
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_key.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.infra-cluster-AmazonEKSClusterPolicy]
}

# Create launch template for EKS define KMS key and enable metadata.
resource "aws_launch_template" "eks_with_kms" {
  name = "eks_with_kms"

  block_device_mappings {
    device_name = "/dev/xvda" 

    ebs {
      encrypted   = true
      volume_size = 20  # Reduced to 20GB for cost savings
      volume_type = "gp3"
      # Not using custom KMS key to avoid permission issues
      # kms_key_id  = aws_kms_key.eks_key.arn
    }
  }
  
  # ALB controller needs access to EC2 Metadata
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  # Removed the instance profile as requested by the error message
  # EKS will create its own instance profile based on the node role
}

# Define system node group for system apps (ArgoCD, controllers, etc.)
resource "aws_eks_node_group" "system-nodes" {
  force_update_version = true
  cluster_name    = aws_eks_cluster.infra-cluster.name
  node_group_name = "system-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  # Use both private and public subnets for more flexibility
  subnet_ids = concat(
    aws_subnet.private[*].id,
    aws_subnet.public[*].id
  )

  capacity_type  = "ON_DEMAND"
  instance_types = var.system_node_instance_type

  scaling_config {
    desired_size = var.system_nodes_desired_size
    max_size     = var.system_nodes_max_size
    min_size     = var.system_nodes_min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "system"
  }
  
  # Add taints to ensure only system workloads run on these nodes
  taint {
    key    = "dedicated"
    value  = "system"
    effect = "NO_SCHEDULE"
  }
  
  tags = merge(
    var.finops_tags,
    {
      "node-type" = "system"
    }
  )
  
  # Using the launch template without instance profile
  # EKS will create its own instance profile based on the node role
  launch_template {
    name    = aws_launch_template.eks_with_kms.name
    version = aws_launch_template.eks_with_kms.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.nodes-kms-policy,
    aws_iam_role.nodes,
  ]
}

# Define application node group for user applications
resource "aws_eks_node_group" "app-nodes" {
  force_update_version = true
  cluster_name    = aws_eks_cluster.infra-cluster.name
  node_group_name = "app-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  # Use both private and public subnets for more flexibility
  subnet_ids = concat(
    aws_subnet.private[*].id,
    aws_subnet.public[*].id
  )

  capacity_type  = "ON_DEMAND"
  instance_types = var.app_node_instance_type

  scaling_config {
    desired_size = var.app_nodes_desired_size
    max_size     = var.app_nodes_max_size
    min_size     = var.app_nodes_min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "application"
  }
  
  tags = merge(
    var.finops_tags,
    {
      "node-type" = "application"
    }
  )
  
  # Using the launch template without instance profile
  # EKS will create its own instance profile based on the node role
  launch_template {
    name    = aws_launch_template.eks_with_kms.name
    version = aws_launch_template.eks_with_kms.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.nodes-kms-policy,
    aws_iam_role.nodes,
  ]
}

# Allow access to EKS cluster from VPN network.
resource "aws_security_group_rule" "eks_pritunl_access" {
  type                     = "ingress"
  from_port               = 443
  to_port                 = 443
  protocol                = "tcp"
  source_security_group_id = aws_security_group.pritunl.id
  description             = "Allow access from pritunl to EKS cluster"
  security_group_id       = aws_eks_cluster.infra-cluster.vpc_config[0].cluster_security_group_id

  depends_on = [aws_eks_cluster.infra-cluster]
}

# Install ArgoCD.
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_version
  
  set {
    name  = "params.server.insecure"
    value = "true"
  }
  
  # Add node selector to schedule ArgoCD components on system nodes
  set {
    name  = "global.nodeSelector.role"
    value = "system"
  }
  
  # Add tolerations for the system node taint
  set {
    name  = "global.tolerations[0].key"
    value = "dedicated"
  }
  
  set {
    name  = "global.tolerations[0].value"
    value = "system"
  }
  
  set {
    name  = "global.tolerations[0].operator"
    value = "Equal"
  }
  
  set {
    name  = "global.tolerations[0].effect"
    value = "NoSchedule"
  }

  depends_on = [
    aws_eks_node_group.system-nodes,
    aws_security_group_rule.eks_pritunl_access
  ]
}