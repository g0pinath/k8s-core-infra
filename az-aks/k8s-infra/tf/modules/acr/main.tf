resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  location            = var.acr_location
  resource_group_name = var.acr_rg_name
  sku                      = var.acr_sku
  #make it premium for PROD
  admin_enabled            = true
  #georeplication_locations = ["Australia East", "Australia SouthEast"]
}