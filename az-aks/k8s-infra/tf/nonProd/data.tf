data "azurerm_resource_group" "rg_devops_core" {
  name = var.dev_rg_group_name
  #"RG-DEV-K8S-CLUSTER" -- default if env var wasnt set to specify RGNAME while running script.
  
}

