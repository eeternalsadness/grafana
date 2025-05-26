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

variable "repo-path-alerts" {
  description = "The path in the repo where Grafana alerting resources are configured"
  type        = string
  default     = "envs/minikube/alerts"
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

variable "vault-mount-kv" {
  description = "The path in Vault where the kvv2 secrets backend is mounted"
  type        = string
  default     = "kvv2"
}

variable "vault-path-kv-data-sources" {
  description = "The path in Vault where data sources' kvv2 secrets are stored"
  type        = string
  default     = "grafana/data_sources"
}

variable "vault-path-kv-contact-point-googlechat" {
  description = "The path in Vault where Google chat contact points' kvv2 secrets are stored"
  type        = string
  default     = "grafana/contact_points/googlechat"
}

variable "vault-path-kv-contact-point-slack" {
  description = "The path in Vault where Slack contact points' kvv2 secrets are stored"
  type        = string
  default     = "grafana/contact_points/slack"
}

variable "vault-path-kv-contact-point-telegram" {
  description = "The path in Vault where Telegram contact points' kvv2 secrets are stored"
  type        = string
  default     = "grafana/contact_points/telegram"
}

variable "vault-path-kv-contact-point-discord" {
  description = "The path in Vault where Discord contact points' kvv2 secrets are stored"
  type        = string
  default     = "grafana/contact_points/discord"
}
