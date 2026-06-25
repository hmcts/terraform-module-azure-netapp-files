output "resource_group_name" {
  description = "The name of the resource group containing the NetApp resources."
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The Azure region of the resource group."
  value       = local.resource_group_location
}

output "netapp_account_id" {
  description = "The ID of the NetApp account."
  value       = azurerm_netapp_account.this.id
}

output "netapp_account_name" {
  description = "The name of the NetApp account."
  value       = azurerm_netapp_account.this.name
}

output "netapp_pool_id" {
  description = "The ID of the NetApp capacity pool."
  value       = azurerm_netapp_pool.this.id
}

output "netapp_pool_name" {
  description = "The name of the NetApp capacity pool."
  value       = azurerm_netapp_pool.this.name
}

output "volume_ids" {
  description = "Map of volume key to volume resource ID."
  value       = { for k, v in azurerm_netapp_volume.this : k => v.id }
}

output "volume_names" {
  description = "Map of volume key to volume name."
  value       = { for k, v in azurerm_netapp_volume.this : k => v.name }
}

output "mount_ip_addresses" {
  description = "Map of volume key to the list of IPv4 mount addresses."
  value       = { for k, v in azurerm_netapp_volume.this : k => v.mount_ip_addresses }
}
