resource "azurerm_postgresql_flexible_server" "this" {

  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version = var.postgres_version

  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  sku_name = var.sku_name

  storage_mb = 32768

  delegated_subnet_id = var.delegated_subnet_id

  private_dns_zone_id = var.private_dns_zone_id

  public_network_access_enabled = false

  tags = var.tags

  depends_on = [
    var.private_dns_zone_id
  ]

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }
}