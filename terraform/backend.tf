terraform {
  backend "azurerm" {
    resource_group_name  = "RG-TFSTATE"
    storage_account_name = "stctmptfstate"
    container_name       = "tfstate"
    key                  = "ctmp.tfstate"
  }
}