#locals {
#  message-templates = {
#    for file_path in fileset(path.module, "../../${var.message-templates-config-dir}/*.tpl") :
#    trimsuffix(basename(file_path), ".tpl") => file("${path.module}/${file_path}")
#  }
#}
#
#resource "grafana_message_template" "message-template" {
#  for_each = local.message-templates
#
#  # required
#  name     = each.key
#  template = each.value
#
#  # optional
#  org_id             = var.org-id
#  disable_provenance = true
#}
