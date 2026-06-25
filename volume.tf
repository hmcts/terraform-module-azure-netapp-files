resource "azurerm_netapp_volume" "this" {
  for_each = var.volumes

  name                = "${local.name}-${each.key}-vol"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  account_name        = azurerm_netapp_account.this.name
  pool_name           = azurerm_netapp_pool.this.name

  volume_path                = each.value.volume_path
  service_level              = coalesce(each.value.service_level, var.pool_service_level)
  subnet_id                  = var.subnet_id
  protocols                  = each.value.protocols
  network_features           = each.value.network_features
  security_style             = each.value.security_style
  storage_quota_in_gb        = each.value.storage_quota_in_gb
  snapshot_directory_visible = each.value.snapshot_directory_visible
  zone                       = coalesce(each.value.zone, var.default_zone)

  dynamic "export_policy_rule" {
    for_each = each.value.export_policy_rules
    content {
      rule_index          = export_policy_rule.value.rule_index
      allowed_clients     = export_policy_rule.value.allowed_clients
      protocols_enabled   = coalesce(export_policy_rule.value.protocols, each.value.protocols)
      unix_read_only      = export_policy_rule.value.unix_read_only
      unix_read_write     = export_policy_rule.value.unix_read_write
      root_access_enabled = export_policy_rule.value.root_access_enabled
    }
  }

  tags = local.merged_tags

  lifecycle {
    prevent_destroy = true

    precondition {
      condition     = !(var.enable_diagnostic_settings && var.log_analytics_workspace_id == null)
      error_message = "log_analytics_workspace_id must be set when enable_diagnostic_settings is true."
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "volume" {
  for_each = var.enable_diagnostic_settings ? var.volumes : {}

  name                       = "${local.name}-${each.key}-vol-diag"
  target_resource_id         = azurerm_netapp_volume.this[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
