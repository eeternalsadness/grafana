#############################
# REPO PATHS
#############################

variable "repo-path-organization" {
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
  description = "The path in the repo where Grafana folders are configured"
  type        = string
  default     = "envs/minikube/folders"
}

variable "repo-path-data-sources" {
  description = "The path in the repo where Grafana data sources are configured"
  type        = string
  default     = "envs/minikube/data-sources"
}

variable "repo-path-dashboards" {
  description = "The path in the repo where Grafana dashboards are configured"
  type        = string
  default     = "envs/minikube/dashboards"
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
