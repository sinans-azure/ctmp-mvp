
resource "azurerm_web_application_firewall_policy" "this" {

  name = "waf-ctmp"

  resource_group_name = var.resource_group_name

  location = var.location

  policy_settings {
    enabled = true
    mode    = "Prevention"
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_public_ip" "this" {

  name = "pip-agw-ctmp"

  resource_group_name = var.resource_group_name

  location = var.location

  allocation_method = "Static"

  sku = "Standard"
}

resource "azurerm_application_gateway" "this" {

  name = "agw-ctmp"

  resource_group_name = var.resource_group_name

  location = var.location

  firewall_policy_id = azurerm_web_application_firewall_policy.this.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name = "gateway-ip-config"

    subnet_id = var.agw_subnet_id
  }

  frontend_port {
    name = "http"

    port = 80
  }

  frontend_ip_configuration {
    name = "public"

    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "placeholder"
  }

  backend_http_settings {
    name = "http"

    cookie_based_affinity = "Disabled"

    port = 80

    protocol = "Http"

    request_timeout = 60
  }

  http_listener {
    name = "listener"

    frontend_ip_configuration_name = "public"

    frontend_port_name = "http"

    protocol = "Http"
  }

  request_routing_rule {

    name = "rule"

    rule_type = "Basic"

    http_listener_name = "listener"

    backend_address_pool_name = "placeholder"

    backend_http_settings_name = "http"

    priority = 100
  }
}
