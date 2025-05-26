locals {
  notification-policy = merge(
    one([
      for file_path in fileset(path.module, "../../${var.notification-policy-config-dir}/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ])
  )
}

resource "grafana_notification_policy" "notification-policy" {
  for_each = local.notification-policy

  # required
  contact_point = grafana_contact_point.contact-point[each.value.contact_point].name
  group_by      = each.value.group_by

  # optional
  org_id             = var.org-id
  disable_provenance = false
  group_interval     = try(each.value.group_interval, null)
  group_wait         = try(each.value.group_wait, null)
  repeat_interval    = try(each.value.repeat_interval, null)

  dynamic "policy" {
    for_each = each.value.policies

    content {
      # optional
      contact_point   = grafana_contact_point.contact-point[policy.value.contact_point].name
      continue        = try(policy.value.continue, false)
      group_by        = try(policy.value.group_by, null)
      group_interval  = try(policy.value.group_interval, null)
      group_wait      = try(policy.value.group_wait, null)
      mute_timings    = try(policy.value.mute_timings, null)
      repeat_interval = try(policy.value.repeat_interval, null)

      dynamic "matcher" {
        for_each = try(policy.value.object_matchers, null) == null ? [] : policy.value.object_matchers

        content {
          # required
          label = matcher.value.label
          match = matcher.value.match
          value = matcher.value.value
        }
      }
    }
  }
}
