terraform {
  backend "s3" {
    bucket = "infra-project-tfstate"
    key    = "dev/lambda_project/us-east-1/tfstate"
    region = "ap-south-1"
    dynamodb_table = "infra-project-statelock"
  }
}