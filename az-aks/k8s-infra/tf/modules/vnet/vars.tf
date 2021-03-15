variable "vnet_properties" {
  type = object({
      node_nsg_name = string
      svc_nsg_name = string
      vnet_name   = string  
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

variable "location" {}
variable "rg_name" {}