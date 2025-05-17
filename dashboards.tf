locals {
  dashboards = merge(
    [
      for file_path in fileset("${path.module}/${var.repo-path-dashboards}", "**/*.yaml") : try(merge([
        for k, v in yamldecode(file("${path.module}/${var.repo-path-dashboards}/${file_path}")) : {
          "${basename(dirname(file_path))}/${k}" = merge({ folder = basename(dirname(file_path)) }, v)
        }
      ]...), {})
    ]...
  )
}

resource "grafana_dashboard" "dashboard" {
  for_each = local.dashboards

  # required
  config_json = file("${path.module}/${var.repo-path-dashboards}/${each.value.folder}/json/${basename(each.key)}.json")

  # optional
  org_id  = grafana_organization.organization.org_id
  folder  = try(one([for folder in grafana_folder.folder : folder.uid if folder.title == each.value.folder]), null)
  message = try(each.value.message, null)
}

resource "grafana_dashboard_permission" "dashboard-permission" {
  for_each = local.dashboards

  # required
  dashboard_uid = grafana_dashboard.dashboard[each.key].uid

  # optional
  org_id = grafana_organization.organization.org_id

  dynamic "permissions" {
    for_each = try(each.value.permissions, {})

    content {
      # required
      permission = permissions.value.permission

      # optional
      role    = try(permissions.value.role, null)
      user_id = try(data.grafana_user.user[permissions.value.user].user_id, null)
    }
  }
}
