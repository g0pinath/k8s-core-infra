
#terraform {
#  backend "azurerm" {
#    resource_group_name  = "RG-DEV-K8S-CLUSTER"
#    storage_account_name = "azaks2021devtf01"
    #should be azaksmetdevtf01 for MSDN subscription
#    container_name       = "tfstate"
#    key                  = "np.terraform.tfstate"

    ##change the values to your RGNAME, SANAME.
#  }
#}

terraform {
  # Intentionally empty. Will be filled by Terragrunt.
  backend "azurerm" {}
}
