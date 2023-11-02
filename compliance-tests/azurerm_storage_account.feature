Feature: Azure Storage Account related security feature

	related resources: azurerm_storage_account
	# policy can handle
	Scenario: Ensure Azure Storage Account enable_https_traffic_only is true
		Given I have azurerm_storage_account defined
		Then it must have enable_https_traffic_only
		And its value must be true
	# policy can handle
	Scenario: Ensure Azure Storage Account min_tls_version is TLS1_2
		Given I have azurerm_storage_account defined
		Then it must have min_tls_version
		And its value must be TLS1_2
	# policy can handle
	Scenario: Ensure Azure Storage Account shared_access_key_enabled is false
		Given I have azurerm_storage_account defined
		Then it must have shared_access_key_enabled
		And its value must be false
	# policy can handle
	Scenario: Ensure Azure Storage Account public_network_access_enabled is false
		Given I have azurerm_storage_account defined
		Then it must have public_network_access_enabled
		And its value must be false

# https://learn.microsoft.com/en-us/azure/storage/common/policy-reference
# Not all settings can be enforced via Azure Policy -- for example container retention policy, CMK

# Policy cant enforce this.
	Scenario: Ensure Azure Storage Account azurerm_storage_account_customer_managed_key is configured
		Given I have azurerm_storage_account defined
		Then it must have customer_managed_key