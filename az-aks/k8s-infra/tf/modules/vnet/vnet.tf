
resource "azurerm_network_security_group" "aks-nsg-aksnodes" {
  name                =  var.vnet_properties.node_nsg_name
  location            = var.location
  resource_group_name = var.rg_name
}


resource "azurerm_network_security_group" "aks-nsg-aksservice" {
  name                = var.vnet_properties.svc_nsg_name
  location            = var.location
  resource_group_name = var.rg_name
}


resource "azurerm_virtual_network" "az-aks-dev-vnet" {
  name                =  var.vnet_properties.vnet_name 
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_properties.vnet_addressspace
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]
  
  subnet {
    name           = var.vnet_properties.nodes_snet_name
    address_prefix = var.vnet_properties.nodes_snet_address
    security_group = azurerm_network_security_group.aks-nsg-aksnodes.id
  }

  subnet {
    name           = var.vnet_properties.appgw_snet_name
    address_prefix = var.vnet_properties.appgw_snet_address
    #security_group = azurerm_network_security_group.aks-nsg-aksservice.id
    
  }

  subnet {
    name           = var.vnet_properties.akssvc_snet_name
    address_prefix = var.vnet_properties.akssvc_snet_address
    security_group = azurerm_network_security_group.aks-nsg-aksservice.id
    
  }


  tags = {
    environment = "nonprod"
  }
}
/*
resource "azurerm_subnet" "appgw" {
  name           = "appgw"
  #security_group = azurerm_network_security_group.aks-nsg-aksnodes.id
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.az-aks-dev-vnet.name
  address_prefixes     = ["10.10.10.0/24"]
}
*/