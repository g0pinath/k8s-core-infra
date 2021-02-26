
resource "azurerm_frontdoor" "afd-np" {
  name                                         = var.afd_name
#  location                                     = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name                          = data.azurerm_resource_group.rg_devops_core.name
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
  
  routing_rule {
    name               = "rr02"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["fep03"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "bep02"
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
      host_header = var.dd_backend_address_host_header 
      address     = var.dd_backend_address
      #endpoint used by front door to reach the DD pod via ingress.
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "lb-config01"
    health_probe_name   = "probe01"
  }

  backend_pool {
    name = "bep02"
    backend {
      host_header = var.grafana_backend_address_host_header 
      address     = var.grafana_backend_address
      #endpoint used by front door to reach the DD pod via ingress.
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "lb-config01"
    health_probe_name   = "probe01"
  }

  frontend_endpoint {
    name                              = "fep01"
    host_name                         =  var.afd_default_host_header
  }
  frontend_endpoint {
    name                              = "fep02"
    host_name                         = var.dd_host_header
  }
  frontend_endpoint {
    name                              = "fep03"
    host_name                         = var.grafana_host_header
  }
  #Dont know why but TF keeps rearranging the order of FP and recreates it every time.
  /*
  lifecycle {
    ignore_changes = [
      frontend_endpoint,
    ]
  }
  */
}

resource "azurerm_frontdoor_custom_https_configuration" "dd_https" {
  frontend_endpoint_id              = azurerm_frontdoor.afd-np[0].frontend_endpoint[1].id
  custom_https_provisioning_enabled = true
  count               = "${var.requireAzureFrontDoor == "true" ? 1 : 0}"
  resource_group_name               = data.azurerm_resource_group.rg_devops_core.name 
# defaults to FrontDoor.Azure will provision the certs (the domains should be verified already in Azure)
  custom_https_configuration {
    
  }
}


resource "azurerm_frontdoor_custom_https_configuration" "grafana_https" {
  frontend_endpoint_id              = azurerm_frontdoor.afd-np[0].frontend_endpoint[2].id
  custom_https_provisioning_enabled = true
  count               = "${var.requireAzureFrontDoor == "true" ? 1 : 0}"
  resource_group_name               = data.azurerm_resource_group.rg_devops_core.name 
# defaults to FrontDoor.Azure will provision the certs (the domains should be verified already in Azure)
  custom_https_configuration {
    
  }
}
