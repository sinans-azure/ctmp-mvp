resource "azurerm_service_plan" "this" {

  name = "${var.function_app_name}-plan"

  resource_group_name = var.resource_group_name

  location = var.location

  os_type = "Linux"

  sku_name = "B1"
}

resource "azurerm_linux_function_app" "this" {

  name = var.function_app_name

  resource_group_name = var.resource_group_name

  location = var.location

  service_plan_id = azurerm_service_plan.this.id

  storage_account_name = var.storage_account_name

  storage_account_access_key = var.storage_account_access_key

  virtual_network_subnet_id = var.subnet_id

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
  }

  tags = var.tags
}

