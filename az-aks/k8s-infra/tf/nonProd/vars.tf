
variable "subscription_id" {  
  type = string
  default = ""
}
variable "client_id" {  
  type = string
  default = ""
}
variable "client_secret" {  
  type = string
  default = ""
}


variable "afd_properties" {
  type = object({
      afd_name = string
      dd_backend_address = string
      grafana_backend_address = string
      techapp_backend_address = string
      dd_backend_address_host_header     = string
      grafana_backend_address_host_header =  string
      techapp_backend_address_host_header =  string
      afd_default_host_header =  string
      dd_host_header = string
      grafana_host_header =  string
      techapp_host_header =  string
      
      
  })
  default = {
      
      afd_name = "cloudkube-dev"
      dd_backend_address = "az-defectdojo-dev.cloudkube.xyz"
      grafana_backend_address     = "az-grafana-dev.cloudkube.xyz"
      techapp_backend_address     = "az-apptio-dev.cloudkube.xyz"

      dd_backend_address_host_header =  "az-defectdojo-dev.cloudkube.xyz"
      grafana_backend_address_host_header =  "az-grafana-dev.cloudkube.xyz"
      techapp_backend_address_host_header =  "az-apptio-dev.cloudkube.xyz"

      afd_default_host_header = "cloudkube-dev.azurefd.net" 
      dd_host_header = "defectdojo-dev.cloudkube.xyz"
      grafana_host_header =  "grafana-dev.cloudkube.xyz"
      techapp_host_header = "apptio-dev.cloudkube.xyz"
      
    }
### The backend address must match the Ingress URL deployed via helm
#For example, if I need to host defectdojo.cloudkube.xyz on Azure Front Door, and the name of the Azure front door is cloudkube
#then I need to publish a CNAME record pointing defectdojo.cloudkube.xyz to cloudkube.azurefd.net

#The backend address has to match defectdojo values file URL and also be present in ingress URLs
#backend_address_host_header dictates the display URL on the browser, if you match this with backend_address then https://defectdojo-dev.cloudkube.xyz will be changed to
#https://az-defectdojo-dev.cloudkube.xyz if you want users to see this URL change, match this to host_header var which is what end users browse in the first place.
#This is a security requirement in DD -- the app has to be acccessed in the URL defined in helm values file.

#afd_default_host_header -- should be afd_name + azurefd.net

}

variable "requireAzureFrontDoor" {
  type = string
  default = "true"
}

variable "IngressController" {
  type = string
  default = "Nginx"
}
variable "tenant_id" {  
  type = string
  default = ""
}


variable "OMSLogging" {
  default = true
  type = bool
}

variable "rg_group_name" {
  default = "RG-DEV-K8S-CLUSTER"
}
#ACR
variable "acr_properties" {
  type = map
  default = {      
      acr_name = "aksacrdev01"
      acr_sku = "Basic"      
    }
  
}

variable "la_name" {
  default = "la01-k8s01-aks-dev"
}

variable "la_properties" {
  type = map
  default = {
      
      la_sku = "PerGB2018"
      la_retention_days = 30
      action_group_name     = "devclemail"
      action_group_name_short =  "devclemail"
      email_receiver_group =  "EmailActionGrp"
      email_receiver_address = "gopithiruvengadam@metricon.com.au"
      
    }
  
}

variable "k8s_properties" {
  type = object({
      
      
      dns_prefix = string
      enable_kube_dashboard = bool
      sys_nodepool_name = string
      sys_pool_size     = string
      sys_pool_min_count =  number
      sys_pool_max_count =  number
      
      apppool01_name = string
      apppool01_size     = string
      apppool01_min_count =  number
      apppool01_max_count =  number
      apppool01_priority  = string
      apppool01_eviction_policy = string
      apppool01_spot_max_price = string
      apppool01_availability_zones = list(string)
      apppool01_max_pods = number
      apppool01_is_spot  = bool

      monitoring_pool_name = string
      monitoring_pool_size     = string
      monitoring_pool_min_count =  number
      monitoring_pool_max_count =  number
      monitoring_pool_priority  = string
      monitoring_pool_eviction_policy = string
      monitoring_pool_spot_max_price = string
      monitoring_pool_availability_zones = list(string)
      monitoring_pool_max_pods = number
      monitoring_pool_is_spot = bool
  })
  default = {
      
      
      dns_prefix = "aks-np-ae"
      enable_kube_dashboard = false
      sys_nodepool_name = "sysnodepool"
      sys_pool_size     = "Standard_A2m_v2"
      sys_pool_min_count =  1
      sys_pool_max_count =  3
      
      apppool01_name = "apppool01"
      apppool01_size     = "Standard_A2m_v2"
      apppool01_min_count =  1
      apppool01_max_count =  10
      apppool01_priority  = "Spot"
      apppool01_eviction_policy = "Delete"
      apppool01_spot_max_price = "-1"
      apppool01_availability_zones =  ["1", "2"]
      apppool01_max_pods = 250
      apppool01_is_spot = true     

      monitoring_pool_name = "monitorpool"
      monitoring_pool_size     = "Standard_A2m_v2"
      monitoring_pool_min_count =  2
      monitoring_pool_max_count =  2
      monitoring_pool_priority  = "Spot"
      monitoring_pool_eviction_policy = "Delete"
      monitoring_pool_spot_max_price = "-1"
      monitoring_pool_availability_zones =  ["1", "2"]
      monitoring_pool_max_pods = 15
      monitoring_pool_is_spot = true
      

    }
  #MSDN subscriptions dont support spot instances, so be sure to set monitoring_pool_is_spot as false for MSDN subscriptions
}

variable "vnet_properties" {
  type = object({
      node_nsg_name = string
      svc_nsg_name = string
      vnet_name = string
      vnet_addressspace     = list(string)
      nodes_snet_name =  string
      appgw_snet_name =  string
      akssvc_snet_name = string
      nodes_snet_address =  string
      appgw_snet_address = string
      akssvc_snet_address = string
      
  })
  default = {
      
      node_nsg_name = "aks-nsg-aksnodes"
      svc_nsg_name = "aks-nsg-aksservice"
      vnet_name     = "az-aks-dev-vnet"
      vnet_addressspace =  ["10.10.0.0/16"]
      nodes_snet_name =  "aksnodes"
      appgw_snet_name = "appgw"
      akssvc_snet_name = "akssvc"
      nodes_snet_address =  "10.10.1.0/24"
      appgw_snet_address = "10.10.10.0/24"
      akssvc_snet_address = "10.10.2.0/23"
      

    }
  
}

variable "k8s_name" {
  default = "aks-met-ae"
}

variable "enable_azure_policy" {
  default = false
}
