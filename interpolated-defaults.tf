locals {
  name = var.name != "" ? var.name : join("-", compact([var.product, var.component, var.env]))

  netapp_account_name = var.netapp_account_name != "" ? var.netapp_account_name : "${local.name}-anf-account"
  pool_name           = var.pool_name != "" ? var.pool_name : "${local.name}-anf-pool"

  resource_group_name     = var.existing_resource_group_name != null ? var.existing_resource_group_name : azurerm_resource_group.rg[0].name
  resource_group_location = var.existing_resource_group_name != null ? var.location : azurerm_resource_group.rg[0].location

  merged_tags = merge(var.common_tags, var.tags)
}
