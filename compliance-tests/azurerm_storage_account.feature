Feature: Azure Storage Account related security feature

	related resources: azurerm_storage_account

	Scenario: Ensure Azure Storage Account enable_https_traffic_only is true
		Given I have azurerm_storage_account defined
		Then it must have enable_https_traffic_only
		And its value must be true

	Scenario: Ensure Azure Storage Account min_tls_version is TLS_2
		Given I have azurerm_storage_account defined
		Then it must have min_tls_version
		And its value must be TLS_2
		
	Scenario: Ensure Azure Storage Account shared_access_key_enabled is false
		Given I have azurerm_storage_account defined
		Then it must have shared_access_key_enabled
		And its value must be false

	Scenario: Ensure Azure Storage Account public_network_access_enabled is false
		Given I have azurerm_storage_account defined
		Then it must have public_network_access_enabled
		And its value must be false