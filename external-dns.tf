resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.22.0"

  values = [
    yamlencode({
      provider = {
        name = "cloudflare"
      }
      env = [
        {
          name  = "CF_API_TOKEN"
          value = var.cloudflare_api_token
        }
      ]
      sources = [
        "ingress"
      ]
      domainFilters = [
        local.domain
      ]
      policy     = "sync"
      txtOwnerId = aws_eks_cluster.eks.name
    })
  ]

  depends_on = [
    aws_eks_node_group.general,
    aws_eks_access_policy_association.sso_admin
  ]
}
