#### Begin ACR #####
module "acr" {
  source = "../modules/acr"

  acr_location            = data.azurerm_resource_group.rg_devops_core.location
  acr_rg_name = data.azurerm_resource_group.rg_devops_core.name
  acr_sku       = var.acr_sku
  acr_name       = var.acr_name

  
}

module "aks" {
  source = "../modules/aks"

  aks_location            = data.azurerm_resource_group.rg_devops_core.location
  aks_rg_name = data.azurerm_resource_group.rg_devops_core.name
  k8s_name       = var.k8s_name
  k8s_properties = var.k8s_properties
  client_id       = var.client_id
  client_secret   = var.client_secret
  OMSLogging       = var.OMSLogging 
  enable_azure_policy = var.enable_azure_policy
  enable_kube_dashboard = var.enable_kube_dashboard
  la_id = "${module.azmonitor.la_id}"
  
}

module "azmonitor" {
  source = "../modules/azmonitor"

  location            = data.azurerm_resource_group.rg_devops_core.location
  rg_name = data.azurerm_resource_group.rg_devops_core.name
  la_properties = var.la_properties
  la_name = var.la_name 

  
}
