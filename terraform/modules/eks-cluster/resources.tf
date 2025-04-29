# Create KMS key for EKS cluster encryption (only for cluster secrets)
resource "aws_kms_key" "eks_key" {
  description             = "KMS key for EKS cluster ${var.cluster_name} secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  # Using default key policy instead of custom one to avoid permission issues
  
  tags = merge(
    var.finops_tags,
    {
      Name = "${var.env}-default"
    }
  )
}

# Create alias for the KMS key
resource "aws_kms_alias" "eks_key_alias" {
  name          = "alias/${var.env}-default"
  target_key_id = aws_kms_key.eks_key.key_id
}

# Create security group for VPN access to EKS
resource "aws_security_group" "pritunl" {
  name        = "infra-pritunl-server-developer"
  description = "Security group for VPN access to EKS cluster"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(
    var.finops_tags,
    {
      Name = "infra-pritunl-server-developer"
    }
  )

  # Allow all traffic from within the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all internal traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  depends_on = [aws_vpc.main]
}