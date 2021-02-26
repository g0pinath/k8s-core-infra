resource "azurerm_kubernetes_cluster" "aks-prdb" {
  name                = var.prd_b_k8s_name
  location            = data.azurerm_resource_group.rg_b_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_b_devops_core.name
  dns_prefix          = var.prd_b_k8s_properties.dns_prefix

  default_node_pool {
    name            = var.prd_b_k8s_properties.sys_nodepool_name
    #node_count      = 1
    min_count       = var.prd_b_k8s_properties.sys_pool_min_count
    max_count       = var.prd_b_k8s_properties.sys_pool_max_count
    vm_size         = var.prd_b_k8s_properties.sys_pool_size
    os_disk_size_gb = 30
    #node_taints     = ["CriticalAddonsOnly=true:NoSchedule"]
    availability_zones = ["1", "2"]
    enable_auto_scaling = true
  }
   
  node_resource_group = "nodes-aks-prd-asea"
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
      enabled = true 
    } #if true cant use PSP
  }

  

  tags = {
    environment = "prod-b"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "apppools-b" {
  name                  = var.prd_b_k8s_properties.small_nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-prdb.id
  vm_size               = var.prd_b_k8s_properties.small_pool_size
  #node_count            = 1
  min_count       = var.prd_b_k8s_properties.small_pool_min_count
  max_count       = var.prd_b_k8s_properties.small_pool_max_count
  availability_zones = ["1", "2"]
  enable_auto_scaling = true
  max_pods    = 30

  tags = {
    Environment = "prod-b"
  }
}
/*
resource "azurerm_kubernetes_cluster_node_pool" "apppools-large" {
  name                  = var.prd_b_k8s_properties.large_nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-np.id
  vm_size               = var.prd_b_k8s_properties.large_pool_size
  #node_count            = 1
  min_count       = var.prd_b_k8s_properties.large_pool_min_count
  max_count       = var.prd_b_k8s_properties.large_pool_max_count
  availability_zones = ["1", "2"]
  enable_auto_scaling = true

  tags = {
    Environment = "nonprod"
  }
}
*/