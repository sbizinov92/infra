terraform {
  backend "s3" {
    bucket         = "terraform-eks-state-bucket"  
    key            = "eks/terraform.tfstate"       
    region         = "eu-west-1"                   
    encrypt        = true                          
    dynamodb_table = "terraform-lock"              
  }
}