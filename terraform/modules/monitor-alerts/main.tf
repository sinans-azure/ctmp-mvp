resource "azurerm_monitor_metric_alert" "postgres_availability" {

  name = "postgres-availability-alert"

  resource_group_name = var.resource_group_name

  scopes = [
    var.postgres_id
  ]

  severity = 2

  frequency = "PT5M"

  window_size = "PT5M"

  criteria {

    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"

    metric_name = "active_connections"

    aggregation = "Average"

    operator = "LessThan"

    threshold = 1
  }

  action {
    action_group_id = var.action_group_id
  }
}
