
resource "azurerm_network_security_group" "aks-nsg-aksnodes" {
  name                = "aks-nsg-aksnodes"
  location            = data.azurerm_resource_group.rg_a_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_a_devops_core.name
}


resource "azurerm_network_security_group" "aks-nsg-aksservice" {
  name                = "aks-nsg-aksservice"
  location            = data.azurerm_resource_group.rg_a_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_a_devops_core.name
}

resource "azurerm_virtual_network" "az-aks-dev-vnet" {
  name                = "az-aks-prd-a-vnet"
  location            = data.azurerm_resource_group.rg_a_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_a_devops_core.name
  address_space       = ["10.11.0.0/16"]
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]
  
  subnet {
    name           = "aksnodes"
    address_prefix = "10.11.1.0/24"
    security_group = azurerm_network_security_group.aks-nsg-aksnodes.id
  }

  subnet {
    name           = "appgw"
    address_prefix = "10.11.10.0/24"
    security_group = azurerm_network_security_group.aks-nsg-aksnodes.id
  }

  subnet {
    name           = "aksservice"
    address_prefix = "10.11.2.0/23"
    security_group = azurerm_network_security_group.aks-nsg-aksservice.id
    
  }


  tags = {
    environment = "nonprod"
  }
}
