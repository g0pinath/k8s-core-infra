
resource "azurerm_monitor_action_group" "actionggroup" {
  name                = var.la_properties.action_group_name
  resource_group_name = var.rg_name
  short_name          = var.la_properties.action_group_name_short
 
 email_receiver {
    name                    = var.la_properties.email_receiver_group
    email_address           = var.la_properties.email_receiver_address
    use_common_alert_schema = true
  }
}

resource "azurerm_log_analytics_workspace" "loganalytics" {
  
  name                = var.la_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.la_properties.la_sku
  retention_in_days   = var.la_properties.la_retention_days
}

# Example: Alerting Action with result count trigger
resource "azurerm_monitor_scheduled_query_rules_alert" "pods_pending" {
  
  name                = "Pods are in Pending state"
  location            = var.location
  resource_group_name = var.rg_name

  action {
    action_group           = [azurerm_monitor_action_group.actionggroup.id]
    email_subject          = "Pods are in Pending state"
    custom_webhook_payload = "{}"
  }
  data_source_id = azurerm_log_analytics_workspace.loganalytics.id
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