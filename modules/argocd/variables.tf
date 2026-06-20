variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart to install"
  type        = string
}

variable "argocd_values_url" {
  description = "Raw GitHub URL of the ArgoCD Helm values file in the GitOps repo"
  type        = string
}

variable "gitops_repo_url" {
  description = "URL of the GitOps repository that the app-of-apps Application watches"
  type        = string
}

variable "app_of_apps_path" {
  description = "Path inside the GitOps repo where ArgoCD Application manifests live"
  type        = string
  default     = "argocd/apps"
}

variable "app_of_apps_url" {
  description = "Raw GitHub URL of the app-of-apps.yaml manifest in the GitOps repo"
  type        = string
}
