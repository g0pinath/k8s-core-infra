

resource "azurerm_kubernetes_cluster" "aks-np" {
  name                = var.k8s_name
  location            = var.aks_location
  resource_group_name = var.aks_rg_name
  dns_prefix          = var.k8s_properties.dns_prefix

  default_node_pool {
    name            = var.k8s_properties.sys_nodepool_name
    #node_count      = 1
    min_count       = var.k8s_properties.sys_pool_min_count
    max_count       = var.k8s_properties.sys_pool_max_count
    vm_size         = var.k8s_properties.sys_pool_size
    os_disk_size_gb = 30
    #node_taints     = ["CriticalAddonsOnly=true:NoSchedule"]
    availability_zones = ["1", "2"]
    enable_auto_scaling = true
  }
   
  node_resource_group = "nodes-aks-np-ae"
  network_profile {
      network_plugin = "azure"
      network_policy = "azure"
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = true
  }
  auto_scaler_profile {

  }

  addon_profile {
    kube_dashboard {
      enabled = var.k8s_properties.enable_kube_dashboard
    }
    oms_agent {
      enabled = var.OMSLogging
      log_analytics_workspace_id = var.la_id
    }
    azure_policy {
      enabled = var.enable_azure_policy 
    } #if true cant use PSP
  }

  

  tags = {
    environment = "nonprod"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "apppool01_spot" {
  count = var.k8s_properties.apppool01_is_spot ? 1 : 0
  name                  = var.k8s_properties.apppool01_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.k8s_properties.apppool01_size
  #node_count            = 1
  min_count       = var.k8s_properties.apppool01_min_count
  max_count       = var.k8s_properties.apppool01_max_count
  availability_zones = var.k8s_properties.apppool01_availability_zones
  #availability_zones = ["1", "2"]
  enable_auto_scaling = true
  max_pods    = var.k8s_properties.apppool01_max_pods
  priority        = var.k8s_properties.apppool01_priority
  eviction_policy = var.k8s_properties.apppool01_eviction_policy
  spot_max_price  = var.k8s_properties.apppool01_spot_max_price

  tags = {
    Environment = "nonprod"
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "monitoring_nodepool_spot" {
  count = var.k8s_properties.monitoring_pool_is_spot ? 1 : 0
  name                  = var.k8s_properties.monitoring_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.k8s_properties.monitoring_pool_size
  #node_count            = 1
  min_count       = var.k8s_properties.monitoring_pool_min_count
  max_count       = var.k8s_properties.monitoring_pool_max_count
  availability_zones = var.k8s_properties.monitoring_pool_availability_zones
  #availability_zones = ["1", "2"]
  enable_auto_scaling = true
  max_pods    = var.k8s_properties.monitoring_pool_max_pods
  priority        = var.k8s_properties.monitoring_pool_priority
  eviction_policy = var.k8s_properties.monitoring_pool_eviction_policy
  spot_max_price  = var.k8s_properties.monitoring_pool_spot_max_price
  tags = {
    Environment = "nonprod"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "apppool01" {
  count = var.k8s_properties.apppool01_is_spot ? 0 : 1
  name                  = var.k8s_properties.apppool01_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.k8s_properties.apppool01_size
  #node_count            = 1
  min_count       = var.k8s_properties.apppool01_min_count
  max_count       = var.k8s_properties.apppool01_max_count
  availability_zones = var.k8s_properties.apppool01_availability_zones
  #availability_zones = ["1", "2"]
  enable_auto_scaling = true
  max_pods    = var.k8s_properties.apppool01_max_pods


  tags = {
    Environment = "nonprod"
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "monitoring_nodepool" {
  count = var.k8s_properties.monitoring_pool_is_spot ? 0 : 1
  name                  = var.k8s_properties.monitoring_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.k8s_properties.monitoring_pool_size
  #node_count            = 1
  min_count       = var.k8s_properties.monitoring_pool_min_count
  max_count       = var.k8s_properties.monitoring_pool_max_count
  availability_zones = var.k8s_properties.monitoring_pool_availability_zones
  #availability_zones = ["1", "2"]
  enable_auto_scaling = true
  max_pods    = var.k8s_properties.monitoring_pool_max_pods

  tags = {
    Environment = "nonprod"
  }
}
