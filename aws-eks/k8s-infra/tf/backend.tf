terraform {
  backend "s3" {
    bucket = "metricon-eks-devsecops-tf"
    key    = "eks-infra"
    region = "ap-southeast-2"
  }
}