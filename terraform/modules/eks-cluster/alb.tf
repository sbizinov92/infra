# AWS Load Balancer Controller resources
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam-policy.json")
}

# Create IAM role for ALB ingress controller
resource "aws_iam_role" "aws_lb_controller_role" {
  name = "AWSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.eks_oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  depends_on = [aws_iam_openid_connect_provider.eks_oidc]
}

# Attach IAM policy to ALB ingress controller
resource "aws_iam_role_policy_attachment" "lb_controller_policy_attachment" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}

# Create service account for ALB ingress controller in kube-system namespace.
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
  }
  
  # Update the depends_on to use system-nodes instead of private-nodes
  depends_on = [aws_eks_node_group.system-nodes]
}

# Install AWS Load Balancer Controller using Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.alb_controller_version

  set {
    name  = "clusterName"
    value = aws_eks_cluster.infra-cluster.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_lb_controller.metadata[0].name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }
  
  # Add node selector to schedule controller on system nodes
  set {
    name  = "nodeSelector.role"
    value = "system"
  }
  
  # Add tolerations for the system node taint
  set {
    name  = "tolerations[0].key"
    value = "dedicated"
  }
  
  set {
    name  = "tolerations[0].value" 
    value = "system"
  }
  
  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }
  
  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  depends_on = [
    kubernetes_service_account.aws_lb_controller,
    aws_eks_node_group.system-nodes
  ]
}