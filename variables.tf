variable "grafana-basic-auth-credentials" {
  description = "The basic auth `username:password` used for authentication for Grafana"
  sensitive   = true
  type        = string
  #default     = null
}

variable "grafana-url" {
  description = "The base URL to access Grafana"
  sensitive   = true
  type        = string
  #default     = null
}

variable "contact-point-secrets" {
  description = "A map of contact point secrets"
  sensitive   = true
  type        = map(any)
  default     = {}
}

variable "data-source-secure-json" {
  description = "A map of secure JSON data for data sources"
  sensitive   = true
  type        = map(map(string))
  default     = null
}

variable "env" {
  description = "The environment to deploy to"
  type        = string
  validation {
    condition     = var.env == "dev" || var.env == "prod"
    error_message = "Invalid env '${var.env}'! Must be 'dev' or 'prod'"
  }
}
