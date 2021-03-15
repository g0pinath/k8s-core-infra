variable "k8s_name" {
  default = ""
}

variable "aks_location" {
  default = ""
}

variable "aks_rg_name" {
  default = ""
}
variable "la_id" {
  default = ""
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
      apppool01_is_spot = bool      

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
      
      
      dns_prefix = "DUMMY"
      enable_kube_dashboard = true
      sys_nodepool_name = "DUMMY"
      sys_pool_size     = "DUMMY"
      sys_pool_min_count =  1
      sys_pool_max_count =  3
      
      apppool01_name = "DUMMY"
      apppool01_size     = "DUMMY"
      apppool01_min_count =  2
      apppool01_max_count =  10
      apppool01_priority  = "DUMMY"
      apppool01_eviction_policy = "DUMMY"
      apppool01_spot_max_price = "-1"
      apppool01_availability_zones = ["1", "2"]
      apppool01_max_pods = 100
      apppool01_is_spot = false

      monitoring_pool_name = "DUMMY"
      monitoring_pool_size     = "DUMMY"
      monitoring_pool_min_count =  2
      monitoring_pool_max_count =  4
      monitoring_pool_priority  = "DUMMY"
      monitoring_pool_eviction_policy = "DUMMY"
      monitoring_pool_spot_max_price = "-1"
      monitoring_pool_availability_zones = ["1", "2"]
      monitoring_pool_max_pods = 10
      monitoring_pool_is_spot = false
    }
  
}

variable "OMSLogging" {
  default = ""
}

variable "enable_azure_policy" {}

variable "client_id" {
  default = ""
}


variable "client_secret" {
  default = ""
}

