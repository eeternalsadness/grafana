#locals {
#  data-sources-resource = merge(
#    [
#      for file_path in fileset(path.module, "config/${var.env}/data-sources/*.yaml") :
#      try(yamldecode(file("${path.module}/${file_path}")), {})
#    ]...
#  )
#}
#
#resource "grafana_data_source" "data-source" {
#  for_each = local.data-sources-resource
#
#  # required
#  name = each.value.name
#  type = each.value.type
#
#  # optional
#  org_id                   = grafana_organization.organization[one(keys(grafana_organization.organization))].org_id
#  uid                      = try(each.value.uid, null)
#  access_mode              = try(each.value.access_mode, null)
#  basic_auth_enabled       = try(each.value.basic_auth_enabled, null)
#  basic_auth_username      = try(each.value.basic_auth_username, null)
#  database_name            = try(each.value.database_name, null)
#  http_headers             = try(each.value.http_headers, null)
#  is_default               = try(each.value.is_default, false)
#  json_data_encoded        = try(jsonencode(each.value.json_data), null)
#  secure_json_data_encoded = try(var.data-source-secure-json[each.key], null) == null ? null : jsonencode(var.data-source-secure-json[each.key])
#  url                      = try(each.value.url, null)
#  username                 = try(each.value.username, null)
#}
