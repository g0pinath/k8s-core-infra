#provider "grafana/terraform-provider-grafana" {
#  url    = "https://metgrafdev.metricon.com.au"
#  auth   = "" 
  #from env var GRAFANA_AUTH in USERNAME:PASSWORD format or the API token.
#  org_id = 1
#}

provider "grafana/grafana" {
  url    = "http://grafana.example.com/"
  auth   = "1234abcd"
  org_id = 1
}