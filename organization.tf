locals {
  users = merge(
    [
      for file_path in fileset(path.module, "config/${var.env}/organization/users/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ]...
  )

  # TODO: refactor for multiple orgs later
  organization = try(yamldecode(file("${path.module}/config/${var.env}/organization/organization.yaml")), {})
}

resource "grafana_organization" "organization" {
  for_each = local.organization

  # required
  name = each.value.name

  # optional
  # NOTE: we don't create users
  create_users = false
  admin_user   = try(each.value.admin_user, null)

  # NOTE: prevent tf plan from always adding `admin@localhost` to the list of admins
  admins  = [for user in local.users : user.email if user.role == "Admin" && user.email != "admin@localhost"]
  editors = [for user in local.users : user.email if user.role == "Editor"]
  viewers = [for user in local.users : user.email if user.role == "Viewer"]
  #users_without_access = []
}

data "grafana_user" "user" {
  for_each = local.users

  email = each.value.email
}
