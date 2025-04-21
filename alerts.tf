module "alerts" {
  source = "./modules/alerts"

  contact-point-secrets = var.contact-point-secrets
  org-id                = grafana_organization.organization[one(keys(grafana_organization.organization))].org_id

  # NOTE: map folder names to uids
  folder-uids                    = { for k, v in grafana_folder.folder : v.title => v.uid }
  rule-groups-config-dir         = "config/${var.env}/alerts/rule-groups"
  contact-points-config-dir      = "config/${var.env}/alerts/contact-points"
  message-templates-config-dir   = "config/${var.env}/alerts/message-templates"
  notification-policy-config-dir = "config/${var.env}/alerts/notification-policy"
  mute-timings-config-dir        = "config/${var.env}/alerts/mute-timings"
}
