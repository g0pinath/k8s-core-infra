
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
variable prd_email {
  default = "gopinath.sastra@gmail.com"
}
#azure frontdoor vars
variable "afd_name" {
  type = string
  default = "cloudkube"  #for each custom domain name hosted by AFD there needs to be an equivalent CNAME pointing to <afd_name>.azurefd.net
  #For example, if I need to host defectdojo.cloudkube.xyz on Azure Front Door, and the name of the Azure front door is cloudkube
  #then I need to publish a CNAME record pointing defectdojo.cloudkube.xyz to cloudkube.azurefd.net
}

variable "backend_address" {
  type = string
  default = "az-defectdojo-prd-a.cloudkube.xyz"
}
variable "backend_address_host_header" {
  type = string
  default = "az-defectdojo-prd-a.cloudkube.xyz" 
  #public DNS should point this to the IP of nginx public IP
  #this should also be set as the host URL for DefectDojo.
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
  default = "cloudkube.azurefd.net" 
} #should be afd_name + azurefd.net 
variable "host_header" {
  type = string
  default = "defectdojo.cloudkube.xyz"
  #There has to be a publis DNS (CNAME) pointing this URL -> afd_name.azurefd.net
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

variable "prd_a_rg_group_name" {
  type = string
  default = ""
}

variable "acr_name" {
  type = string
  default = "aksacrprda01"
}

variable "prd_a_la_name" {
  type = string
  default = "az-aks-prda"
}

variable "prd_a_k8s_properties" {
  type = map
  default = {
      
      dns_prefix = "AKS-PRD-A-AE"
      sys_nodepool_name = "sysnodepool"
      sys_pool_size     = "Standard_B2S"
      sys_pool_min_count =  1
      sys_pool_max_count =  1
      
      small_nodepool_name = "smallpool"
      small_pool_size     = "Standard_B2S"
      small_pool_min_count =  1
      small_pool_max_count =  2

      large_nodepool_name = "largepool"
      large_pool_size     = "Standard_B2S"
      large_pool_min_count =  1
      large_pool_max_count =  1

    }
  
}

variable "prd_a_k8s_name" {
  type = string
  default = "AKS-PRD-A-AE"
}

