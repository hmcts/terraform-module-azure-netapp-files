variable "env" {
  description = "Environment value"
  type        = string
}

variable "common_tags" {
  description = "Common tag to be applied to resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "ID of the delegated subnet for Azure NetApp Files (must have Microsoft.NetApp/volumes delegation). The subnet must already exist; this module does not create it."
  type        = string
}
