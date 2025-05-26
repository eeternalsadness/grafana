locals {
  contact-points = merge(
    [
      for file_path in fileset(path.module, "../../${var.contact-points-config-dir}/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ]...
  )
}

data "vault_kv_secret_v2" "contact-point-googlechat" {
  for_each = toset([for k, v in local.contact-points : k if contains(keys(v.contact_points), "googlechat")])

  name  = "${var.vault-path-kv-contact-point-googlechat}/${each.value}"
  mount = var.vault-mount-kv
}

data "vault_kv_secret_v2" "contact-point-slack" {
  for_each = toset([for k, v in local.contact-points : k if contains(keys(v.contact_points), "slack")])

  name  = "${var.vault-path-kv-contact-point-slack}/${each.value}"
  mount = var.vault-mount-kv
}

data "vault_kv_secret_v2" "contact-point-telegram" {
  for_each = toset([for k, v in local.contact-points : k if contains(keys(v.contact_points), "telegram")])

  name  = "${var.vault-path-kv-contact-point-telegram}/${each.value}"
  mount = var.vault-mount-kv
}

data "vault_kv_secret_v2" "contact-point-discord" {
  for_each = toset([for k, v in local.contact-points : k if contains(keys(v.contact_points), "discord")])

  name  = "${var.vault-path-kv-contact-point-discord}/${each.value}"
  mount = var.vault-mount-kv
}

resource "grafana_contact_point" "contact-point" {
  for_each = local.contact-points

  # requried
  name = each.value.name

  disable_provenance = false
  org_id             = var.org-id

  # optional
  dynamic "googlechat" {
    for_each = contains(keys(each.value.contact_points), "googlechat") ? ["googlechat"] : []

    content {
      # required
      url     = jsondecode(data.vault_kv_secret_v2.contact-point-googlechat[each.key].data_json).url
      title   = each.value.contact_points["googlechat"].title
      message = each.value.contact_points["googlechat"].message

      # optional
      disable_resolve_message = try(each.value.contact_points["googlechat"].disable_resolve_message, false)
      settings                = try(each.value.contact_points["googlechat"].settings, null)
    }
  }

  # optional
  dynamic "slack" {
    for_each = contains(keys(each.value.contact_points), "slack") ? ["slack"] : []

    content {
      # required
      url   = jsondecode(data.vault_kv_secret_v2.contact-point-slack[each.key].data_json).url
      title = each.value.contact_points["slack"].title
      text  = each.value.contact_points["slack"].message

      # optional
      disable_resolve_message = try(each.value.contact_points["slack"].disable_resolve_message, false)
      endpoint_url            = try(each.value.contact_points["slack"].endpoint_url, null)
      icon_emoji              = try(each.value.contact_points["slack"].icon_emoji, null)
      icon_url                = try(each.value.contact_points["slack"].icon_url, null)
      mention_channel         = try(each.value.contact_points["slack"].mention_channel, null)
      mention_groups          = try(each.value.contact_points["slack"].mention_groups, null)
      mention_users           = try(each.value.contact_points["slack"].mention_users, null)
      recipient               = try(each.value.contact_points["slack"].recipient, null)
      settings                = try(each.value.contact_points["slack"].settings, null)
      token                   = try(each.value.contact_points["slack"].token, null)
      username                = try(each.value.contact_points["slack"].username, null)
    }
  }

  # optional
  dynamic "telegram" {
    for_each = contains(keys(each.value.contact_points), "telegram") ? ["telegram"] : []

    content {
      # required
      chat_id = each.value.contact_points["telegram"].chat_id
      token   = jsondecode(data.vault_kv_secret_v2.contact-point-telegram[each.key].data_json).token

      # optional
      disable_notifications    = try(each.value.contact_points["telegram"].disable_notifications, null)
      disable_resolve_message  = try(each.value.contact_points["telegram"].disable_resolve_message, null)
      disable_web_page_preview = try(each.value.contact_points["telegram"].disable_web_page_preview, null)
      message                  = try(each.value.contact_points["telegram"].message, null)
      message_thread_id        = try(each.value.contact_points["telegram"].message_thread_id, null)
      parse_mode               = try(each.value.contact_points["telegram"].parse_mode, null)
      protect_content          = try(each.value.contact_points["telegram"].protect_content, null)
      settings                 = try(each.value.contact_points["telegram"].settings, null)
    }
  }

  # optional
  dynamic "discord" {
    for_each = contains(keys(each.value.contact_points), "discord") ? ["discord"] : []

    content {
      # required
      url = jsondecode(data.vault_kv_secret_v2.contact-point-discord[each.key].data_json).url

      # optional
      avatar_url              = try(each.value.contact_points["discord"].avatar_url, null)
      disable_resolve_message = try(each.value.contact_points["discord"].disable_resolve_message, null)
      message                 = try(each.value.contact_points["discord"].message, null)
      settings                = try(each.value.contact_points["discord"].settings, null)
      title                   = try(each.value.contact_points["discord"].title, null)
      use_discord_username    = try(each.value.contact_points["discord"].use_discord_username, null)
    }
  }

  depends_on = [grafana_notification_policy.notification-policy]
}
