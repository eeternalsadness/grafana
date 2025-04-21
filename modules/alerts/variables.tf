# contact points
variable "contact-points-config-dir" {
  description = "The relative path of the directory that stores the yaml files for contact point configuration"
  type        = string
}

variable "contact-point-secrets" {
  description = "A map of contact point secrets"
  sensitive   = true
  type        = map(any)
  default     = {}
}

# message templates
variable "message-templates-config-dir" {
  description = "The relative path of the directory that stores the yaml files for message template configuration"
  type        = string
}

# notification policy
variable "notification-policy-config-dir" {
  description = "The relative path of the directory that stores the yaml files for notification policy configuration"
  type        = string
}

# rule groups
variable "rule-groups-config-dir" {
  description = "The relative path of the directory that stores the yaml files for rule group configuration"
  type        = string
}

variable "folder-uids" {
  description = "Map of folder names to uids"
  type        = map(string)
}

# mute timings
variable "mute-timings-config-dir" {
  description = "The relative path of the directory that stores the yaml files for mute timing configuration"
  type        = string
}

variable "org-id" {
  description = "The organization ID for alert resources"
  type        = number
}
