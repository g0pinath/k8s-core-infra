

resource "aws_eks_cluster" "eksdevsecopscluster" {
  name     = "metricon-eks-devsecops"
  role_arn = aws_iam_role.ekscluster.arn

  vpc_config {
    subnet_ids = ["subnet-0559424591c171849", "subnet-06b597fcd4fb7ddfa", "subnet-0c7d26348cd9b9178",
    "subnet-0dd0c99b9d14eb146", "subnet-0e43af2e65fa7adc8", "subnet-0d28683a03b7a52a1"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,    
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eksdevsecopscluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eksdevsecopscluster.certificate_authority[0].data
}
