resource "azurerm_container_registry" "acr" {
  name                     = var.acr_properties.acr_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                      = var.acr_properties.acr_sku
  #make it premium for PROD
  admin_enabled            = true
  #georeplication_locations = ["Australia East", "Australia SouthEast"]
}