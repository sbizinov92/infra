#!/bin/bash
# Script to set up Terraform S3 backend infrastructure

# Configuration
BUCKET_NAME="terraform-eks-state-bucket"  
DYNAMODB_TABLE="terraform-lock"           
AWS_REGION="eu-west-1"                    

# Check AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION

echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

echo "Enabling server-side encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_REGION

echo "Setup complete! Your Terraform backend infrastructure is ready."
echo "S3 bucket: $BUCKET_NAME"
echo "DynamoDB table: $DYNAMODB_TABLE"
echo "Region: $AWS_REGION"
echo ""
echo "Don't forget to update backend.tf files with your bucket name if you changed it."
