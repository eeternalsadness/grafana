locals {
  folders = merge(
    [
      for file_path in fileset(path.module, "config/${var.env}/folders/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ]...
  )
}

resource "grafana_folder" "folder" {
  for_each = local.folders

  # required
  title = each.value.title

  # optional
  org_id                       = grafana_organization.organization[one(keys(grafana_organization.organization))].org_id
  parent_folder_uid            = try(each.value.parent_folder_uid, null)
  prevent_destroy_if_not_empty = try(each.value.prevent_destroy_if_not_empty, null)
  uid                          = try(each.value.uid, null)
}

resource "grafana_folder_permission" "folder-permission" {
  for_each = local.folders

  # required
  folder_uid = grafana_folder.folder[each.key].uid

  # optional
  org_id = grafana_organization.organization[one(keys(grafana_organization.organization))].org_id

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
