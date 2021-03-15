variable "la_name" {
  default = ""
}

variable "location" {
  default = ""
}

variable "rg_name" {
    default = ""
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
      la_name = "az-aks-devsec02"

    }
  
}


