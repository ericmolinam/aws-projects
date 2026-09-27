resource "aws_iam_role" "lbc" {
  name = "${aws_eks_cluster.eks.name}-lbc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lbc" {
  policy = file("./iam/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "lbc" {
  policy_arn = aws_iam_policy.lbc.arn
  role       = aws_iam_role.lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc.arn
}