

remote_state {
    backend = "azurerm"
    config = {
        key = "${path_relative_to_include()}/terraform.tfstate"
        resource_group_name = get_env("K8S_RG_NAME") #"RG-DEV-K8S-CLUSTER"
        storage_account_name = get_env("TF_STORAGE_NAME")
        container_name = "tfstate"
    }
}