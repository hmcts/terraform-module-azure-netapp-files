variable "env" {
  description = "Environment name, e.g. sandbox, dev, prod."
  default     = "sandbox"
}

variable "builtFrom" {
  description = "Source repository URL, used in common tags."
  default     = "hmcts/terraform-module-azure-netapp-files"
}

variable "product" {
  description = "Product name."
  default     = "myapp"
}

variable "subnet_id" {
  description = "ID of the subnet with Microsoft.NetApp/volumes delegation. Must already exist."
  type        = string
}
