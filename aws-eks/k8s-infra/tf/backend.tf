terraform {
  backend "s3" {
    bucket = "cloudkube-eks-nonprod-tf"
    key    = "eks-infra"
    region = "ap-southeast-2"
  }
}
