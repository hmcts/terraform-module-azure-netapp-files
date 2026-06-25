resource "azurerm_netapp_account" "this" {
  name                = local.netapp_account_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

  tags = local.merged_tags
}

resource "azurerm_netapp_pool" "this" {
  name                = local.pool_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  account_name        = azurerm_netapp_account.this.name

  service_level       = var.pool_service_level
  size_in_tb          = var.pool_size_in_tb
  qos_type            = var.pool_qos_type
  cool_access_enabled = var.pool_cool_access_enabled
  encryption_type     = var.pool_encryption_type

  tags = local.merged_tags
}
