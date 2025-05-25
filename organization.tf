locals {
  users = merge(
    [
      for file_path in fileset("${path.module}/${var.repo-path-organization-users}", "*.yaml") :
      try(yamldecode(file("${path.module}/${var.repo-path-organization-users}/${file_path}")), {})
    ]...
  )

  organization = yamldecode(file("${path.module}/${var.repo-path-organization}"))
}

resource "grafana_organization" "organization" {
  # required
  name = local.organization.name

  # optional
  # NOTE: we don't create users
  create_users = false

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

data "vault_kv_secret_v2" "oauth2" {
  name  = local.organization.oauth2.vaultSecretPath
  mount = var.vault-mount-kv
}

resource "grafana_sso_settings" "oauth2" {
  provider_name = local.organization.oauth2.providerName
  oauth2_settings {
    name                       = local.organization.oauth2.name
    client_id                  = jsondecode(data.vault_kv_secret_v2.oauth2.data_json).client_id
    client_secret              = jsondecode(data.vault_kv_secret_v2.oauth2.data_json).client_secret
    allow_sign_up              = local.organization.oauth2.allowSignUp
    auto_login                 = local.organization.oauth2.autoLogin
    scopes                     = local.organization.oauth2.scopes
    skip_org_role_sync         = true
    allow_assign_grafana_admin = false
    #allowed_domains     = "gmail.com"
    #role_attribute_path = "email=='69bnguyen@gmail.com' && 'Admin' || 'Viewer'"
  }
}
