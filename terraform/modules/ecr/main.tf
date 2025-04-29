# Create an ECR repository for the echoserver image
resource "aws_ecr_repository" "echoserver" {
  name                 = "echoserver"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Enable encryption
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

# Create a repository policy to allow pull access only if a role ARN is provided
resource "aws_ecr_repository_policy" "echoserver_policy" {
  count = var.eks_node_role_arn != "" ? 1 : 0
  
  repository = aws_ecr_repository.echoserver.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPull",
        Effect = "Allow",
        Principal = {
          AWS = var.eks_node_role_arn
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
      }
    ]
  })
}

# Create lifecycle policy to clean up old images
resource "aws_ecr_lifecycle_policy" "echoserver_lifecycle" {
  repository = aws_ecr_repository.echoserver.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep only the last 10 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}