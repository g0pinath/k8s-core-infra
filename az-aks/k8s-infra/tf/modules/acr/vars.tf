
variable "location" {
  default = ""
}

variable "rg_name" {
  default = ""
}

variable "acr_properties" {
  type = map
  default = {      
      acr_name = "aksacrdev01"
      acr_sku = "Basic"      
    }
  
}