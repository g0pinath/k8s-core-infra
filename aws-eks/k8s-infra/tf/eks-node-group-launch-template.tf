resource "aws_launch_template" "eks_tagging_template" {
  name = "eks-tagging-template01"


    tag_specifications {
    resource_type = "instance"

    tags = {
        Owner = "MTG"
        Application = "DevOpsTools"
        ManagedBy = "Application Team"
        Environment = "Development"
        "Name" = "EKS-AppPool-Nodes"
    }
  }


}