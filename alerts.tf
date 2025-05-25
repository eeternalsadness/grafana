module "alerts" {
  source = "./modules/alerts"

  org-id = grafana_organization.organization.org_id

  vault-mount-kv                         = var.vault-mount-kv
  vault-path-kv-contact-point-googlechat = var.vault-path-kv-contact-point-googlechat
  vault-path-kv-contact-point-slack      = var.vault-path-kv-contact-point-slack
  vault-path-kv-contact-point-telegram   = var.vault-path-kv-contact-point-telegram

  # NOTE: map folder names to uids
  folder-uids                    = { for k, v in grafana_folder.folder : v.title => v.uid }
  rule-groups-config-dir         = "${var.repo-path-alerts}/rule-groups"
  contact-points-config-dir      = "${var.repo-path-alerts}/contact-points"
  message-templates-config-dir   = "${var.repo-path-alerts}/message-templates"
  notification-policy-config-dir = "${var.repo-path-alerts}/notification-policy"
  mute-timings-config-dir        = "${var.repo-path-alerts}/mute-timings"
}
