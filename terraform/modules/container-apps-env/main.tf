resource "azurerm_container_app_environment" "this" {

  name = var.environment_name

  location = var.location

  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_workspace_id

  infrastructure_subnet_id = var.infrastructure_subnet_id

  internal_load_balancer_enabled = true

  public_network_access          = "Disabled"

  tags = var.tags
}
