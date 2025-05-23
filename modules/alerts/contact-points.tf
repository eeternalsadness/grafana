locals {
  contact-points = merge(
    [
      for file_path in fileset(path.module, "../../${var.contact-points-config-dir}/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ]...
  )
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
      url     = var.contact-point-secrets[each.key]["googlechat"]["url"]
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
      url   = var.contact-point-secrets[each.key]["slack"]["url"]
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
      token   = var.contact-point-secrets[each.key]["telegram"]["token"]

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
}

