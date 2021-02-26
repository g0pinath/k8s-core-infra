

resource "aws_eks_node_group" "system-pool" {
  cluster_name    = aws_eks_cluster.eksdevsecopscluster.name
  node_group_name = "system-pool"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids = ["subnet-0559424591c171849", "subnet-06b597fcd4fb7ddfa"] 
  # "subnet-0c7d26348cd9b9178"
  # There is an issue with EBS where the PV could be in 2a and the nodes could end up in 2b/c. For N number of zones, we need that many number of minimum nodes for PV to be bound.
  #We want to run with least number of nodes possible that gives HA and hence are using only 2 AZ.
  capacity_type = "SPOT"
  launch_template {
    name    = "eks-tagging-template01"
    version = aws_launch_template.eks_tagging_template.latest_version
  }
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }  

   tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.eksdevsecopscluster.name}" = "shared"
    "Owner" = "MTG"
    "Application" = "DevOpsTools"
    "ManagedBy" = "Application Team"
    "Environment" = "Development"
    "Name" = "EKS-System-Nodes"
  }

  
  depends_on = [
    
  ]
}
# Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
# Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
# Node group tags wont propagate to the instances automatically. If the node instances need to be tagged, use EKSCTL and launch templates.

resource "aws_eks_node_group" "devsecops-pool" {
  cluster_name    = aws_eks_cluster.eksdevsecopscluster.name
  node_group_name = "devsecops-pool"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids = ["subnet-0559424591c171849", "subnet-06b597fcd4fb7ddfa", "subnet-0c7d26348cd9b9178"]
  capacity_type = "SPOT"
  instance_types = ["t3.large"]
  launch_template {
    name    = "eks-tagging-template01"
    version = aws_launch_template.eks_tagging_template.latest_version
  }
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }  

   tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.eksdevsecopscluster.name}" = "shared"
    "Owner" = "MTG"
    "Application" = "DevOpsTools"
    "ManagedBy" = "Application Team"
    "Environment" = "Development"
    "Name" = "EKS-AppPool-Nodes"

  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  # Node group tags wont propagate to the instances automatically. If the node instances need to be tagged, use EKSCTL and launch templates.
  depends_on = [
    
  ]
}
