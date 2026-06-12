resource "azurerm_storage_account" "this" {

  name = var.storage_account_name

  resource_group_name = var.resource_group_name

  location = var.location

  account_tier = "Standard"

  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_storage_container" "lab_guides" {

  name = "lab-guides"

  storage_account_id = azurerm_storage_account.this.id

  container_access_type = "private"
}

resource "azurerm_storage_container" "templates" {

  name = "templates"

  storage_account_id = azurerm_storage_account.this.id

  container_access_type = "private"
}

resource "azurerm_storage_container" "generated" {

  name = "generated"

  storage_account_id = azurerm_storage_account.this.id

  container_access_type = "private"
}

resource "azurerm_storage_queue" "instance_requests" {
  name               = "instance-requests"
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_storage_queue" "notifications" {
  name               = "notifications"
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_storage_queue" "audit_events" {
  name               = "audit-events"
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_private_endpoint" "storage" {

  name = "${var.storage_account_name}-pe"

  location = var.location

  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {

    name = "storage-connection"

    private_connection_resource_id = azurerm_storage_account.this.id

    subresource_names = [
      "blob"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name                 = "blob"
    private_dns_zone_ids = [var.blob_private_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "queue" {

  name = "${var.storage_account_name}-queue-pe"

  location = var.location

  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {

    name = "queue-connection"

    private_connection_resource_id = azurerm_storage_account.this.id

    subresource_names = [
      "queue"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name                 = "queue"
    private_dns_zone_ids = [var.queue_private_dns_zone_id]
  }
}
