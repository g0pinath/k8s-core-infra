terraform {
  backend "azurerm" {
    resource_group_name  = "RG-PRD-A-K8S-CLUSTER"
    storage_account_name = "azaks2021prdatf01"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}