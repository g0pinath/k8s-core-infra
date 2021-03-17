
variable "location" {
  default = ""
}

variable "rg_name" {
    default = ""
}
variable "requireAzureFrontDoor" {
  default = false
}
variable "afd_properties" {
  type = object({
      afd_name = string
      dd_backend_address = string
      grafana_backend_address = string
      dd_backend_address_host_header     = string
      grafana_backend_address_host_header =  string
      afd_default_host_header =  string
      dd_host_header = string
      grafana_host_header =  string
      
      
  })
  default = {
      
      afd_name = "DUMMY"
      dd_backend_address = "DUMMY"
      grafana_backend_address     = "DUMMY"
      dd_backend_address_host_header =  "DUMMY"
      grafana_backend_address_host_header =  "DUMMY"
      afd_default_host_header = "DUMMY" 
      dd_host_header = "DUMMY"
      grafana_host_header =  "DUMMY"

      
    }
#For example, if I need to host defectdojo.cloudkube.xyz on Azure Front Door, and the name of the Azure front door is cloudkube
#then I need to publish a CNAME record pointing defectdojo.cloudkube.xyz to cloudkube.azurefd.net

#The backend address has to match defectdojo values file URL and also be present in ingress URLs
#backend_address_host_header dictates the display URL on the browser, if you match this with backend_address then https://defectdojo-dev.cloudkube.xyz will be changed to
#https://az-defectdojo-dev.cloudkube.xyz if you want users to see this URL change, match this to host_header var which is what end users browse in the first place.
#This is a security requirement in DD -- the app has to be acccessed in the URL defined in helm values file.

#afd_default_host_header -- should be afd_name + azurefd.net

}


