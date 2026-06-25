terraform {
  required_version = ">= 1.2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    netapp {
      prevent_volume_destruction             = true
      delete_backups_on_backup_vault_destroy = false
    }
  }
}
