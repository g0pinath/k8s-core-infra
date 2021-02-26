
resource "azurerm_monitor_action_group" "ag" {
  name                = "Dev-EmailActionGrp"
  resource_group_name = data.azurerm_resource_group.rg_devops_core.name
  short_name          = "devclemail"
 
 email_receiver {
    name                    = "Dev-EmailActionGrp"
    email_address           = var.dev_email
    use_common_alert_schema = true
  }
}

resource "azurerm_log_analytics_workspace" "la" {
  
  name                = var.dev_la_name
  location            = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_devops_core.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Example: Alerting Action with result count trigger
resource "azurerm_monitor_scheduled_query_rules_alert" "pods_pending" {
  
  name                = "Pods are in Pending state"
  location            = data.azurerm_resource_group.rg_devops_core.location
  resource_group_name = data.azurerm_resource_group.rg_devops_core.name

  action {
    action_group           = [azurerm_monitor_action_group.ag.id]
    email_subject          = "Pods are in Pending state"
    custom_webhook_payload = "{}"
  }
  data_source_id = azurerm_log_analytics_workspace.la.id
  description    = "Alert when total results cross threshold"
  enabled        = true
  # Count all requests with server error result code grouped into 5-minute bins
  query       = <<-QUERY
  let trendBinSize = 1m; 
  KubePodInventory | where "a" == "a" |
  where TimeGenerated > ago(6m) |  join KubeEvents on Name, $left.Name == $right.Name | 
  extend PodName = Name | where PodStatus in ('Pending') | where "a" == "a"

  QUERY
  severity    = 1
  frequency   = 5
  time_window = 5
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
}