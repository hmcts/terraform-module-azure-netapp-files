# ─── Naming & resource group ─────────────────────────────────────────────────

variable "existing_resource_group_name" {
  description = "Name of an existing resource group to deploy resources into. When set, no resource group is created by this module."
  type        = string
  default     = null
}

variable "location" {
  description = "Target Azure location to deploy the resource."
  type        = string
  default     = "UK South"
}

variable "name" {
  description = "Override for the default name, which is built as <product>-<component>-<env>. Only the product+component portion can be overridden here."
  type        = string
  default     = ""
}

variable "product" {
  description = "Name of the product, e.g. 'myapp'. Used in the default naming convention."
  type        = string
  default     = null
}

variable "component" {
  description = "Name of the component, e.g. 'storage'. Used in the default naming convention."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to merge with common_tags."
  type        = map(string)
  default     = {}
}

# ─── NetApp Account ───────────────────────────────────────────────────────────

variable "netapp_account_name" {
  description = "Override the auto-generated NetApp account name. Defaults to '<name>-anf-account'."
  type        = string
  default     = ""
}

# ─── Capacity Pool ────────────────────────────────────────────────────────────

variable "pool_name" {
  description = "Override the auto-generated capacity pool name. Defaults to '<name>-anf-pool'."
  type        = string
  default     = ""
}

variable "pool_service_level" {
  description = "The service level of the capacity pool. Possible values are Standard, Premium, Ultra, and Flexible. Defaults to Premium."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Standard", "Premium", "Ultra", "Flexible"], var.pool_service_level)
    error_message = "pool_service_level must be one of: Standard, Premium, Ultra, Flexible."
  }
}

variable "pool_size_in_tb" {
  description = "Provisioned size of the capacity pool in TB. Value must be between 1 and 2048."
  type        = number
  default     = 4

  validation {
    condition     = var.pool_size_in_tb >= 1 && var.pool_size_in_tb <= 2048
    error_message = "pool_size_in_tb must be between 1 and 2048."
  }
}

variable "pool_qos_type" {
  description = "QoS type for the capacity pool. Valid values are Auto or Manual. Defaults to Auto."
  type        = string
  default     = "Auto"

  validation {
    condition     = contains(["Auto", "Manual"], var.pool_qos_type)
    error_message = "pool_qos_type must be Auto or Manual."
  }
}

variable "pool_cool_access_enabled" {
  description = "Whether the capacity pool can hold cool access enabled volumes. Defaults to false. Once enabled, cannot be disabled without recreating the resource."
  type        = bool
  default     = false
}

variable "pool_encryption_type" {
  description = "Encryption type of the pool. Valid values are Single and Double. Defaults to Single. Changing this forces a new resource."
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Double"], var.pool_encryption_type)
    error_message = "pool_encryption_type must be Single or Double."
  }
}

# ─── Zone redundancy ─────────────────────────────────────────────────────────

variable "default_zone" {
  description = <<-EOT
    Default availability zone for all volumes that do not specify their own zone.
    Possible values are "1", "2", or "3". Set to null to deploy volumes without a
    specific zone placement (non-zonal). Defaults to "1" for zone-redundant placement.

    Note: Zone-aware volume placement requires the 'availabilityZones' preview feature
    to be registered on the subscription:
      az feature register --namespace Microsoft.NetApp --name ANFAvailabilityZone
  EOT
  type        = string
  default     = "1"

  validation {
    condition     = var.default_zone == null || contains(["1", "2", "3"], var.default_zone)
    error_message = "default_zone must be null or one of: \"1\", \"2\", \"3\"."
  }
}

# ─── Volumes ──────────────────────────────────────────────────────────────────

variable "volumes" {
  description = <<-EOT
    Map of volumes to create within the capacity pool. The map key is used as a short label
    and forms part of the default volume name (<name>-<key>-vol).

    Each volume object supports the following fields:
      - volume_path                (required) Unique file path for the volume, used for mount targets.
      - storage_quota_in_gb        (required) Maximum storage quota in GB.
      - protocols                  (optional) List of protocols. Supported values: NFSv3, NFSv4.1, CIFS. Defaults to ["NFSv4.1"].
      - service_level              (optional) Overrides the pool service level for this volume. Defaults to pool_service_level.
      - network_features           (optional) Network feature tier: Basic or Standard. Defaults to Standard.
      - security_style             (optional) Volume security style: unix or ntfs. Defaults to unix for NFS volumes.
      - snapshot_directory_visible (optional) Whether the .snapshot directory is visible. Defaults to false.
      - zone                       (optional) Availability zone: "1", "2", or "3". Overrides default_zone for this volume.
      - export_policy_rules        (optional) List of NFS export policy rules (not applicable for CIFS volumes).
        - rule_index          (required) Index number of the rule (must be unique within the volume).
        - allowed_clients     (required) List of allowed client IPv4 addresses or CIDR ranges.
        - protocols           (optional) List of protocols for this rule. Defaults to the volume protocols.
        - unix_read_only      (optional) Whether the export is read-only. Defaults to false.
        - unix_read_write     (optional) Whether the export is read-write. Defaults to true.
        - root_access_enabled (optional) Whether root access is permitted. Defaults to false.
  EOT
  type = map(object({
    volume_path                = string
    storage_quota_in_gb        = number
    protocols                  = optional(list(string), ["NFSv4.1"])
    service_level              = optional(string)
    network_features           = optional(string, "Standard")
    security_style             = optional(string, "unix")
    snapshot_directory_visible = optional(bool, false)
    zone                       = optional(string)
    export_policy_rules = optional(list(object({
      rule_index          = number
      allowed_clients     = list(string)
      protocols           = optional(list(string))
      unix_read_only      = optional(bool, false)
      unix_read_write     = optional(bool, true)
      root_access_enabled = optional(bool, false)
    })), [])
  }))

  validation {
    condition = alltrue([
      for k, v in var.volumes : alltrue([
        for p in v.protocols : contains(["NFSv3", "NFSv4.1", "CIFS"], p)
      ])
    ])
    error_message = "Volume protocols must be one of: NFSv3, NFSv4.1, CIFS."
  }

  validation {
    condition = alltrue([
      for k, v in var.volumes :
      contains(["Basic", "Standard"], v.network_features)
    ])
    error_message = "network_features must be Basic or Standard."
  }

  validation {
    condition = alltrue([
      for k, v in var.volumes :
      contains(["unix", "ntfs"], v.security_style)
    ])
    error_message = "security_style must be unix or ntfs."
  }
}

# ─── Diagnostic settings ──────────────────────────────────────────────────────

variable "enable_diagnostic_settings" {
  description = "Whether to create a diagnostic setting for each NetApp volume. Requires log_analytics_workspace_id when true."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace to send diagnostics to. Required when enable_diagnostic_settings is true."
  type        = string
  default     = null
}
