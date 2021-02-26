
resource "azurerm_frontdoor" "afd-prd" {
  name                                         = var.afd_name
#  location                                     = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name                          = data.azurerm_resource_group.rg_a_devops_core.name
  enforce_backend_pools_certificate_name_check = false
  count               = "${var.requireAzureFrontDoor == "true" ? 1 : 0}"
  routing_rule {
    name               = "rr01"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["fep02"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "bep01"
    }
  }

  backend_pool_load_balancing {
    name = "lb-config01"
  }

  backend_pool_health_probe {
    name = "probe01"
  }

  backend_pool {
    name = "bep01"
    backend {
      host_header = var.backend_address_host_header 
      address     = var.backend_address
      #endpoint used by front door to reach the DD pod via ingress.
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "lb-config01"
    health_probe_name   = "probe01"
  }

  frontend_endpoint {
    name                              = "fep01"
    host_name                         = var.afd_default_host_header
    
  }
  frontend_endpoint {
    name                              = "fep02"
    host_name                         = var.host_header
    #endpoint exposed to the world.
    
  }
}

resource "azurerm_frontdoor_custom_https_configuration" "https" {
  frontend_endpoint_id              = azurerm_frontdoor.afd-prd[0].frontend_endpoint[1].id
  custom_https_provisioning_enabled = true
  count               = "${var.requireAzureFrontDoor == "true" ? 1 : 0}"
  resource_group_name               = data.azurerm_resource_group.rg_a_devops_core.name 
# defaults to FrontDoor.Azure will provision the certs (the domains should be verified already in Azure)
  custom_https_configuration {
    
  }
}