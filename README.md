# terraform-module-azure-netapp-files

Terraform module for [Azure NetApp Files](https://learn.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-introduction).

Provisions a NetApp account, a capacity pool, and one or more NFS/SMB volumes. The delegated subnet must be created separately before calling this module.

## Example

```hcl
module "netapp_files" {
  source = "git@github.com:hmcts/terraform-module-azure-netapp-files?ref=main"

  env       = var.env
  product   = "myapp"
  component = "storage"

  common_tags = var.common_tags

  # Delegated subnet (Microsoft.NetApp/volumes) — must already exist
  subnet_id = "/subscriptions/.../subnets/netapp-subnet"

  pool_service_level = "Standard"
  pool_size_in_tb    = 4

  volumes = {
    data = {
      volume_path         = "myapp-storage-sandbox-data"
      storage_quota_in_gb = 100
      protocols           = ["NFSv4.1"]
      export_policy_rules = [
        {
          rule_index      = 1
          allowed_clients = ["10.0.0.0/24"]
          unix_read_write = true
        }
      ]
    }
  }
}
```

## Deploying the Example

You can deploy the example resource using this module to the CNP `DTS-SHAREDSERVICESPTL-SBOX` subscription via the Azure DevOps pipeline.

To run the pipeline:

1. Navigate to the pipeline in Azure DevOps.
2. Click **Run pipeline**.
3. Tick the **`deploy_example`** checkbox.
4. Select the desired **`overrideAction`** (`plan`, `apply`, or `destroy`).
5. Click **Run**.

The pipeline will deploy the resources defined in the [example/](example/) directory to the sandbox subscription.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.78.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.volume](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_netapp_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_account) | resource |
| [azurerm_netapp_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_pool) | resource |
| [azurerm_netapp_volume.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_volume) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tag to be applied to resources | `map(string)` | n/a | yes |
| <a name="input_component"></a> [component](#input\_component) | Name of the component, e.g. 'storage'. Used in the default naming convention. | `string` | `null` | no |
| <a name="input_default_zone"></a> [default\_zone](#input\_default\_zone) | Default availability zone for all volumes that do not specify their own zone.<br/>Possible values are "1", "2", or "3". Set to null to deploy volumes without a<br/>specific zone placement (non-zonal). Defaults to "1" for zone-redundant placement.<br/><br/>Note: Zone-aware volume placement requires the 'availabilityZones' preview feature<br/>to be registered on the subscription:<br/>  az feature register --namespace Microsoft.NetApp --name ANFAvailabilityZone | `string` | `"1"` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Whether to create a diagnostic setting for each NetApp volume. Requires log\_analytics\_workspace\_id when true. | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment value | `string` | n/a | yes |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Name of an existing resource group to deploy resources into. When set, no resource group is created by this module. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Target Azure location to deploy the resource. | `string` | `"UK South"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace to send diagnostics to. Required when enable\_diagnostic\_settings is true. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Override for the default name, which is built as <product>-<component>-<env>. Only the product+component portion can be overridden here. | `string` | `""` | no |
| <a name="input_netapp_account_name"></a> [netapp\_account\_name](#input\_netapp\_account\_name) | Override the auto-generated NetApp account name. Defaults to '<name>-anf-account'. | `string` | `""` | no |
| <a name="input_pool_cool_access_enabled"></a> [pool\_cool\_access\_enabled](#input\_pool\_cool\_access\_enabled) | Whether the capacity pool can hold cool access enabled volumes. Defaults to false. Once enabled, cannot be disabled without recreating the resource. | `bool` | `false` | no |
| <a name="input_pool_encryption_type"></a> [pool\_encryption\_type](#input\_pool\_encryption\_type) | Encryption type of the pool. Valid values are Single and Double. Defaults to Single. Changing this forces a new resource. | `string` | `"Single"` | no |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Override the auto-generated capacity pool name. Defaults to '<name>-anf-pool'. | `string` | `""` | no |
| <a name="input_pool_qos_type"></a> [pool\_qos\_type](#input\_pool\_qos\_type) | QoS type for the capacity pool. Valid values are Auto or Manual. Defaults to Auto. | `string` | `"Auto"` | no |
| <a name="input_pool_service_level"></a> [pool\_service\_level](#input\_pool\_service\_level) | The service level of the capacity pool. Possible values are Standard, Premium, Ultra, and Flexible. Defaults to Premium. | `string` | `"Premium"` | no |
| <a name="input_pool_size_in_tb"></a> [pool\_size\_in\_tb](#input\_pool\_size\_in\_tb) | Provisioned size of the capacity pool in TB. Value must be between 1 and 2048. | `number` | `4` | no |
| <a name="input_product"></a> [product](#input\_product) | Name of the product, e.g. 'myapp'. Used in the default naming convention. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the delegated subnet for Azure NetApp Files (must have Microsoft.NetApp/volumes delegation). The subnet must already exist; this module does not create it. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge with common\_tags. | `map(string)` | `{}` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Map of volumes to create within the capacity pool. The map key is used as a short label<br/>and forms part of the default volume name (<name>-<key>-vol).<br/><br/>Each volume object supports the following fields:<br/>  - volume\_path                (required) Unique file path for the volume, used for mount targets.<br/>  - storage\_quota\_in\_gb        (required) Maximum storage quota in GB.<br/>  - protocols                  (optional) List of protocols. Supported values: NFSv3, NFSv4.1, CIFS. Defaults to ["NFSv4.1"].<br/>  - service\_level              (optional) Overrides the pool service level for this volume. Defaults to pool\_service\_level.<br/>  - network\_features           (optional) Network feature tier: Basic or Standard. Defaults to Standard.<br/>  - security\_style             (optional) Volume security style: unix or ntfs. Defaults to unix for NFS volumes.<br/>  - snapshot\_directory\_visible (optional) Whether the .snapshot directory is visible. Defaults to false.<br/>  - zone                       (optional) Availability zone: "1", "2", or "3". Overrides default\_zone for this volume.<br/>  - export\_policy\_rules        (optional) List of NFS export policy rules (not applicable for CIFS volumes).<br/>    - rule\_index          (required) Index number of the rule (must be unique within the volume).<br/>    - allowed\_clients     (required) List of allowed client IPv4 addresses or CIDR ranges.<br/>    - protocols           (optional) List of protocols for this rule. Defaults to the volume protocols.<br/>    - unix\_read\_only      (optional) Whether the export is read-only. Defaults to false.<br/>    - unix\_read\_write     (optional) Whether the export is read-write. Defaults to true.<br/>    - root\_access\_enabled (optional) Whether root access is permitted. Defaults to false. | <pre>map(object({<br/>    volume_path                = string<br/>    storage_quota_in_gb        = number<br/>    protocols                  = optional(list(string), ["NFSv4.1"])<br/>    service_level              = optional(string)<br/>    network_features           = optional(string, "Standard")<br/>    security_style             = optional(string, "unix")<br/>    snapshot_directory_visible = optional(bool, false)<br/>    zone                       = optional(string)<br/>    export_policy_rules = optional(list(object({<br/>      rule_index          = number<br/>      allowed_clients     = list(string)<br/>      protocols           = optional(list(string))<br/>      unix_read_only      = optional(bool, false)<br/>      unix_read_write     = optional(bool, true)<br/>      root_access_enabled = optional(bool, false)<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mount_ip_addresses"></a> [mount\_ip\_addresses](#output\_mount\_ip\_addresses) | Map of volume key to the list of IPv4 mount addresses. |
| <a name="output_netapp_account_id"></a> [netapp\_account\_id](#output\_netapp\_account\_id) | The ID of the NetApp account. |
| <a name="output_netapp_account_name"></a> [netapp\_account\_name](#output\_netapp\_account\_name) | The name of the NetApp account. |
| <a name="output_netapp_pool_id"></a> [netapp\_pool\_id](#output\_netapp\_pool\_id) | The ID of the NetApp capacity pool. |
| <a name="output_netapp_pool_name"></a> [netapp\_pool\_name](#output\_netapp\_pool\_name) | The name of the NetApp capacity pool. |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | The Azure region of the resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the NetApp resources. |
| <a name="output_volume_ids"></a> [volume\_ids](#output\_volume\_ids) | Map of volume key to volume resource ID. |
| <a name="output_volume_names"></a> [volume\_names](#output\_volume\_names) | Map of volume key to volume name. |
<!-- END_TF_DOCS -->

## Contributing

We use pre-commit hooks for validating the terraform format and maintaining the documentation automatically.
Install it with:

```shell
$ brew install pre-commit terraform-docs
$ pre-commit install
```

If you add a new hook make sure to run it against all files:
```shell
$ pre-commit run --all-files
```

