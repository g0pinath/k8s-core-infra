resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  location            = data.azurerm_resource_group.rg_b_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_b_devops_core.name
  sku                      = "Basic"
  #should be premium for PROD
  admin_enabled            = true
  #georeplication_locations = ["Australia East", "Australia SouthEast"]
}