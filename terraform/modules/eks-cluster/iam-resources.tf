# Create IAM role for EKS cluster
resource "aws_iam_role" "infra-cluster" {
  name = var.cluster_name
  tags = {
    tag-key = var.cluster_name
  }

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# Create IAM role for EKS nodes with necessary permissions.
resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
inline_policy {
  name   = "${var.env}_ecr_pull"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeImageScanFindings"
        ],
         
        Resource = [
          "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.this.account_id}:repository/${var.env}/*",
          "arn:aws:ecr:${var.aws_region}:${var.aws_addon_registry}:repository/*" 
        ] #  Addon registry are mandatory for CNI to work.
      },
      {
        Effect = "Allow",
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      }      
    ]
  })
}
}
# Manage EKS cluster policies.
resource "aws_iam_role_policy_attachment" "infra-cluster-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.infra-cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Add ECR read access
resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Add KMS permissions for EKS nodes
resource "aws_iam_policy" "node_kms_policy" {
  name        = "EKSNodeKMSPolicy"
  description = "Policy that grants KMS permissions to EKS nodes"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ],
        Resource = aws_kms_key.eks_key.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nodes-kms-policy" {
  policy_arn = aws_iam_policy.node_kms_policy.arn
  role       = aws_iam_role.nodes.name
}

# Create IAM instance profile for the node groups
# This is kept for reference but not used in the launch template
# EKS node group will create its own instance profile based on the node role
resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.nodes.name
}