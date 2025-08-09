locals {
  message-templates = merge(
    [
      for file_path in fileset(path.module, "../../${var.message-templates-config-dir}/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ]...
  )
}

resource "grafana_message_template" "message-template" {
  for_each = local.message-templates

  # required
  name     = each.value.name
  template = each.value.template

  # optional
  org_id             = var.org-id
  disable_provenance = true
}

