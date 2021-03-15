
resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  location            = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_devops_core.name
  allocation_method   = "Static"
  sku                 = "Standard"
  count               = "${var.IngressController == "AppGW" ? 1 : 0}"
}



#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.az-aks-dev-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.az-aks-dev-vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.az-aks-dev-vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.az-aks-dev-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.az-aks-dev-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.az-aks-dev-vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.az-aks-dev-vnet.name}-rdrcfg"
  subet_id                      = "${azurerm_virtual_network.az-aks-dev-vnet.id}/subnets/appgw"
}


resource "azurerm_application_gateway" "agw-dev-ae-aks01" {
  name                = "agw-dev-ae-aks01"
  location            = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_devops_core.name
  count               = "${var.IngressController == "AppGW" ? 1 : 0}"
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"

  }
  autoscale_configuration {
      min_capacity = 0
      max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = local.subet_id
    #join(separator , [])
    
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip[0].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                    = "devvotingapp.cloudkube.xyz"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
