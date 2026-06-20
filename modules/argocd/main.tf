terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.0"
    }
  }
}

data "http" "argocd_values" {
  url = var.argocd_values_url
}

data "http" "app_of_apps" {
  url = var.app_of_apps_url
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  values = [data.http.argocd_values.response_body]
}

resource "kubectl_manifest" "app_of_apps" {
  yaml_body = data.http.app_of_apps.response_body

  depends_on = [helm_release.argocd]
}
