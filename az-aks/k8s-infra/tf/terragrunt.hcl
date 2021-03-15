

remote_state {
    backend = "azurerm"
    config = {
        key = "${path_relative_to_include()}/terraform.tfstate"
        resource_group_name = "RG-DEV-K8S-CLUSTER"
        storage_account_name = "azaksmetdevtf01"
        container_name = "tfstate"
    }
}