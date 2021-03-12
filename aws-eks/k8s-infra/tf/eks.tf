

resource "aws_eks_cluster" "eksdevsecopscluster" {
  name     = "cloudkube-eks-nonprod"
  role_arn = aws_iam_role.ekscluster.arn

  vpc_config {
    subnet_ids = ["subnet-17599d5f", "subnet-a7dc16c1", "subnet-4e89cc16"]
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
