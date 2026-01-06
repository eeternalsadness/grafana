# contact points
variable "contact-points-config-dir" {
  description = "The relative path of the directory that stores the yaml files for contact point configuration"
  type        = string
}

# message templates
#variable "message-templates-config-dir" {
#  description = "The relative path of the directory that stores the yaml files for message template configuration"
#  type        = string
#}

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

variable "vault-mount-kv" {
  description = "The path in Vault where the kvv2 secrets backend is mounted"
  type        = string
}

variable "vault-path-kv-contact-point-googlechat" {
  description = "The path in Vault where Google chat contact points' kvv2 secrets are stored"
  type        = string
}

variable "vault-path-kv-contact-point-slack" {
  description = "The path in Vault where Slack contact points' kvv2 secrets are stored"
  type        = string
}

variable "vault-path-kv-contact-point-telegram" {
  description = "The path in Vault where Telegram contact points' kvv2 secrets are stored"
  type        = string
}

variable "vault-path-kv-contact-point-discord" {
  description = "The path in Vault where Discord contact points' kvv2 secrets are stored"
  type        = string
}
