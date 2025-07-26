terraform {
  backend "s3" {
    bucket         = "orabi-tfstate"
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
