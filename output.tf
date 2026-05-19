output "kubeconfig_path" {
  value = local.kubeconfig_path
}
output "kubectl_use" {
  value = "KUBECONFIG=$(terraform output -raw kubeconfig_path) kubectl get nodes"
}