# locate SSO Roles dynamically
data "aws_iam_roles" "sso_admin" {
  name_regex  = "^AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "sso_poweruser" {
  name_regex  = "^AWSReservedSSO_PowerUserAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

# AdministratorAccess
resource "aws_eks_access_entry" "admin_sso" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = tolist(data.aws_iam_roles.sso_admin.arns)[0]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_sso" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin_sso.principal_arn

  access_scope {
    type = "cluster"
  }
}

# PowerUserAccess
resource "aws_eks_access_entry" "dev_sso" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = tolist(data.aws_iam_roles.sso_poweruser.arns)[0]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "dev_sso" {
  cluster_name = aws_eks_cluster.eks.name
  # AmazonEKSEditPolicy (read/write workloads) or AmazonEKSViewPolicy (read-only)
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = aws_eks_access_entry.dev_sso.principal_arn

  access_scope {
    type = "cluster" # or "namespace", e.g. namespaces = ["default"]
  }
}