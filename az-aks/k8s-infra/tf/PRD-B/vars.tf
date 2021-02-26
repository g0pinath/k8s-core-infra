
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
variable "requireAzureFrontDoor" {
  type = string
  default = "false" 
  #should always be false for B region. AFD is a global resoure that will be deployed when primary region is deployed.
}

variable prd_email {
  default = "gopinath.sastra@gmail.com"
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

variable "prd_b_rg_group_name" {
  type = string
  default = ""
}

variable "acr_name" {
  type = string
  default = "aksacrprdb01"
}

variable "prd_b_la_name" {
  type = string
  default = ""
}

variable "prd_b_k8s_properties" {
  type = map
  default = {
      
      dns_prefix = "AKS-PRD-B-ASEA"
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

variable "prd_b_k8s_name" {
  type = string
  default = ""
}

