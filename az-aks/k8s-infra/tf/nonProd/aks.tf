

resource "azurerm_kubernetes_cluster" "aks-np" {
  name                = var.k8s_name
  location            = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_devops_core.name
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
      enabled = true
    }
    oms_agent {
      enabled = var.OMSLogging
      log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
    }
    azure_policy {
      enabled = var.enable_azure_policy 
    } #if true cant use PSP
  }

  

  tags = {
    environment = "nonprod"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "apppools" {
  name                  = var.k8s_properties.small_nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.k8s_properties.small_pool_size
  #node_count            = 1
  min_count       = var.k8s_properties.small_pool_min_count
  max_count       = var.k8s_properties.small_pool_max_count
  availability_zones = ["1", "2"]
  enable_auto_scaling = true
  max_pods    = 100
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = "-1"

  tags = {
    Environment = "nonprod"
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "apppools-monitoring" {
  name                  = var.k8s_properties.monitoring_nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.k8s_properties.monitoring_pool_size
  #node_count            = 1
  min_count       = var.k8s_properties.monitoring_pool_min_count
  max_count       = var.k8s_properties.monitoring_pool_max_count
  availability_zones = ["1", "2"]
  enable_auto_scaling = true
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = "-1"
  tags = {
    Environment = "nonprod"
  }
}
