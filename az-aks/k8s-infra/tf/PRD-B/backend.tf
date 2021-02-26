terraform {
  backend "azurerm" {
    resource_group_name  = "RG-PRD-B-K8S-CLUSTER"
    storage_account_name = "azaks2021prdbtf01"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    #Replace RGNAME and SA Name
  }
}