variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "cluster_name" {
  type    = string
  default = "k8s-flux"
}

variable "GITHUB_OWNER" {
  type = string
}
variable "GITHUB_TOKEN" {
  type = string
}
variable "FLUX_GITHUB_REPO" {
  type = string
}