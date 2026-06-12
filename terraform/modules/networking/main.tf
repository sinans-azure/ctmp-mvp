resource "azurerm_virtual_network" "this" {

  name = var.vnet_name

  location = var.location

  resource_group_name = var.resource_group_name

  address_space = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "this" {

  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = each.value.address_prefixes

  dynamic "delegation" {
    for_each = try(each.value.delegation, null) != null ? [1] : []

    content {
      name = "delegation"

      service_delegation {
        name = each.value.delegation

        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }
}