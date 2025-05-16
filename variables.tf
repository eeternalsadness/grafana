#############################
# REPO PATHS
#############################

variable "repo-path-grafana-organization" {
  description = "The path in the repo where the Grafana organization is configured"
  type        = string
  default     = "envs/minikube/organization/organization.yaml"
}

variable "repo-path-organization-users" {
  description = "The path in the repo where Grafana users are configured"
  type        = string
  default     = "envs/minikube/organization/users"
}

variable "repo-path-folders" {
  default = "envs/minikube/folders"
}

#############################
# GRAFANA
#############################

#############################
# VAULT
#############################

variable "vault-max-lease-ttl-seconds" {
  description = "Duration of intermediate tokens that Terraform gets from Vault"
  type        = number
  default     = 600 # 10 minutes
}
