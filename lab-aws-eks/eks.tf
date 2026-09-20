# EKS Cluster configuration
resource "aws_eks_cluster" "eks" {
  role_arn = aws_iam_role.eks.arn

  name    = local.eks_name
  version = local.eks_version

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

    # Collects the IDs of all private subnets created via for_each
    subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}

# EKS Node groups
resource "aws_eks_node_group" "general" {
  node_role_arn = aws_iam_role.nodes.arn

  cluster_name    = aws_eks_cluster.eks.name
  version         = local.eks_version
  node_group_name = "general"

  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  capacity_type  = "SPOT"
  instance_types = ["t3.small", "t3a.small", "t2.small"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  # Allow external changes to the desired size of the node group without causing a Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}