module "netapp_files" {
  source = "../"

  env       = var.env
  product   = var.product
  component = "storage"

  common_tags = {
    "managedBy"    = "Terraform"
    "environment"  = var.env
    "application"  = "core"
    "businessArea" = "Cross-Cutting"
    "expiresAfter" = "2027-01-01"
    "builtFrom"    = "https://github.com/hmcts/terraform-module-azure-netapp-files"
  }

  location = "UK South"

  # The delegated subnet must already exist with Microsoft.NetApp/volumes delegation.
  # Recommended minimum size is /26.
  subnet_id = var.subnet_id

  # Capacity pool — Premium tier, 4 TB minimum.
  # Volumes are placed in zone "1" by default (default_zone = "1").
  # Override default_zone at the module level, or per-volume via the zone field.
  pool_service_level = "Premium"
  pool_size_in_tb    = 4

  volumes = {
    # Key is used as part of the volume name: <product>-<component>-<env>-<key>-vol
    data = {
      volume_path         = "myapp-storage-sandbox-data"
      storage_quota_in_gb = 100
      protocols           = ["NFSv4.1"]
      network_features    = "Standard"
      security_style      = "unix"

      export_policy_rules = [
        {
          rule_index          = 1
          allowed_clients     = ["10.0.0.0/24"]
          unix_read_write     = true
          unix_read_only      = false
          root_access_enabled = false
        }
      ]
    }
  }

  # Uncomment to enable diagnostic settings
  # enable_diagnostic_settings = true
  # log_analytics_workspace_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/my-law"
}

output "netapp_account_id" {
  value = module.netapp_files.netapp_account_id
}

output "netapp_pool_id" {
  value = module.netapp_files.netapp_pool_id
}

output "mount_ip_addresses" {
  value = module.netapp_files.mount_ip_addresses
}
