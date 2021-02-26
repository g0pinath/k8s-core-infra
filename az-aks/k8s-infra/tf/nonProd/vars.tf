
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

variable "vnet_name" {
  default = "az-aks-dev-vnet"
}

variable "OMSLogging" {
  default = false
}

variable "dev_rg_group_name" {
  type = string
  default = "RG-DEV-K8S-CLUSTER"
}
variable "acr_name" {
  type = string
  default = "aksacrdev01"
}

variable "dev_la_name" {
  type = string
  default = "az-aks-devsec02"
}

variable "k8s_properties" {
  type = map
  default = {
      
      dns_prefix = "aks-np-ae"
      sys_nodepool_name = "sysnodepool"
      sys_pool_size     = "Standard_B2S"
      sys_pool_min_count =  2
      sys_pool_max_count =  4
      
      small_nodepool_name = "smallpool"
      small_pool_size     = "Standard_B2S"
      small_pool_min_count =  2
      small_pool_max_count =  4

      large_nodepool_name = "largepool"
      large_pool_size     = "Standard_B2S"
      large_pool_min_count =  2
      large_pool_max_count =  4

    }
  
}

variable "k8s_name" {
  type = string
  default = "aks-np-ae"
} 
#For AKS - enable Azure policies or not.
variable "enable_azure_policy" {
  default = false 
}