
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
variable dev_email {
  default = "gopinath.sastra@gmail.com"
}
#azure frontdoor vars
variable "afd_name" {
  type = string
  default = "cloudkube-dev"  #for each custom domain name hosted by AFD there needs to be an equivalent CNAME pointing to <afd_name>.azurefd.net
  #For example, if I need to host defectdojo.cloudkube.xyz on Azure Front Door, and the name of the Azure front door is cloudkube
  #then I need to publish a CNAME record pointing defectdojo.cloudkube.xyz to cloudkube.azurefd.net
}

variable "dd_backend_address" {
  type = string
  default = "az-defectdojo-dev.cloudkube.xyz"
}
variable "grafana_backend_address" {
  type = string
  default = "az-grafana-dev.cloudkube.xyz"
}

variable "dd_backend_address_host_header" {
  type = string
  default = "az-defectdojo-dev.cloudkube.xyz"
}

variable "grafana_backend_address_host_header" {
  type = string
  default = "az-grafana-dev.cloudkube.xyz"
}
#The backend address has to match defectdojo values file URL and also be present in ingress URLs
#backend_address_host_header dictates the display URL on the browser, if you match this with backend_address then https://defectdojo-dev.cloudkube.xyz will be changed to
#https://az-defectdojo-dev.cloudkube.xyz if you want users to see this URL change, match this to host_header var which is what end users browse in the first place.
#This is a security requirement in DD -- the app has to be acccessed in the URL defined in helm values file.
variable "requireAzureFrontDoor" {
  type = string
  default = "true"
}
variable "afd_default_host_header" {
  default = "cloudkube-dev.azurefd.net" 
} #should be afd_name + azurefd.net
variable "dd_host_header" {
  type = string
  default = "defectdojo-dev.cloudkube.xyz"
}

variable "grafana_host_header" {
  type = string
  default = "grafana-dev.cloudkube.xyz"
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
  default = false
}

variable "dev_rg_group_name" {
  type = string
  default = "RG-DEV-K8S-CLUSTER"
}
#ACR
variable "acr_name" {
  type = string
  default = "aksacrdev01"
}

variable "acr_sku" {
  type = string
  default = "Basic"
}
variable "la_name" {
  default = "az-aks-devsec02"
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
      enable_kube_dashboard = true
      sys_nodepool_name = "sysnodepool"
      sys_pool_size     = "Standard_B2s"
      sys_pool_min_count =  1
      sys_pool_max_count =  3
      
      apppool01_name = "apppool01"
      apppool01_size     = "Standard_B2ms"
      apppool01_min_count =  1
      apppool01_max_count =  4
      apppool01_priority  = "Spot"
      apppool01_eviction_policy = "Delete"
      apppool01_spot_max_price = "-1"
      apppool01_availability_zones =  ["1", "2"]
      apppool01_max_pods = 100
      apppool01_is_spot = false     

      monitoring_pool_name = "monitorpool"
      monitoring_pool_size     = "Standard_B2ms"
      monitoring_pool_min_count =  1
      monitoring_pool_max_count =  2
      monitoring_pool_priority  = "Spot"
      monitoring_pool_eviction_policy = "Delete"
      monitoring_pool_spot_max_price = "-1"
      monitoring_pool_availability_zones =  ["1", "2"]
      monitoring_pool_max_pods = 15
      monitoring_pool_is_spot = false
      

    }
  
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
