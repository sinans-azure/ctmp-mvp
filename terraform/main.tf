locals {
  current_env = local.environment_config[var.environment]
}

module "resource_group" {

  source = "./modules/resource-group"

  resource_group_name = local.current_env.rg_name

  location = var.location

  tags = local.tags
}

module "networking" {

  source = "./modules/networking"

  vnet_name = local.current_env.vnet_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  address_space = local.current_env.address_space

  subnets = local.current_env.subnets

  tags = local.tags
}

module "nsgs" {

  for_each = local.current_env.nsgs

  source = "./modules/nsg"

  nsg_name = each.value

  location = var.location

  resource_group_name = module.resource_group.resource_group_name

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = local.current_env.nsgs

  subnet_id = module.networking.subnet_ids[each.key]

  network_security_group_id = module.nsgs[each.key].id
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group.resource_group_name
}

resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = module.resource_group.resource_group_name
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.resource_group.resource_group_name
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = module.resource_group.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "${var.environment}-blob-link"
  resource_group_name   = module.resource_group.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.networking.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  name                  = "${var.environment}-queue-link"
  resource_group_name   = module.resource_group.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  virtual_network_id    = module.networking.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "${var.environment}-keyvault-link"
  resource_group_name   = module.resource_group.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = module.networking.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "${var.environment}-acr-link"
  resource_group_name   = module.resource_group.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = module.networking.vnet_id
}

module "postgres" {

  source = "./modules/postgres"

  server_name = local.current_env.postgres_server_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  admin_username = var.postgres_admin_username
  admin_password = var.postgres_admin_password

  sku_name = "B_Standard_B1ms"

  postgres_version = "17"

  delegated_subnet_id = module.networking.subnet_ids["DBSubnet"]

  private_dns_zone_id = module.postgres_dns.private_dns_zone_id

  tags = local.tags
}

module "postgres_dns" {

  source = "./modules/private-dns"

  resource_group_name = module.resource_group.resource_group_name

  vnet_id = module.networking.vnet_id

  environment = var.environment
}

module "storage" {

  source = "./modules/storage"

  storage_account_name = local.current_env.storage_account_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  private_endpoint_subnet_id = module.networking.subnet_ids["PrivateEndpointsSubnet"]

  blob_private_dns_zone_id = azurerm_private_dns_zone.blob.id

  queue_private_dns_zone_id = azurerm_private_dns_zone.queue.id

  tags = local.tags
}

module "acr" {

  source = "./modules/acr"

  acr_name = local.current_env.acr_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  private_endpoint_subnet_id = module.networking.subnet_ids["PrivateEndpointsSubnet"]

  private_dns_zone_id = azurerm_private_dns_zone.acr.id

  tags = local.tags
}

module "log_analytics" {

  source = "./modules/log-analytics"

  workspace_name = local.current_env.log_workspace_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  tags = local.tags
}

module "container_apps_environment" {

  source = "./modules/container-apps-env"

  environment_name = local.current_env.container_apps_env_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  log_analytics_workspace_id = module.log_analytics.id

  infrastructure_subnet_id = module.networking.subnet_ids["ContainerAppsSubnet"]

  tags = local.tags
}

module "function_app" {

  source = "./modules/function-app"

  function_app_name = local.current_env.function_app_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  storage_account_name = module.storage.storage_account_name

  storage_account_access_key = module.storage.primary_access_key

  subnet_id = module.networking.subnet_ids["FunctionsSubnet"]

  tags = local.tags
}

module "keyvault" {

  source = "./modules/keyvault"

  keyvault_name = local.current_env.keyvault_name

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  private_endpoint_subnet_id = module.networking.subnet_ids["PrivateEndpointsSubnet"]

  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id

  tags = local.tags
}

resource "azurerm_role_assignment" "function_kv" {

  scope = module.keyvault.id

  role_definition_name = "Key Vault Secrets User"

  principal_id = module.function_app.principal_id
}

resource "azurerm_user_assigned_identity" "container_apps" {

  name = "id-containerapps-${var.environment}"

  location = var.location

  resource_group_name = module.resource_group.resource_group_name
}

resource "azurerm_role_assignment" "containerapps_kv" {

  scope = module.keyvault.id

  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_user_assigned_identity.container_apps.principal_id
}

module "app_insights" {

  source = "./modules/app-insights"

  name = local.current_env.app_insights_name

  location = var.location

  resource_group_name = module.resource_group.resource_group_name

  workspace_id = module.log_analytics.id

  tags = local.tags
}

module "action_group" {

  source = "./modules/monitor-action-group"

  name = local.current_env.action_group_name

  short_name = "CTMP"

  resource_group_name = module.resource_group.resource_group_name
}

module "monitor_alerts" {

  source = "./modules/monitor-alerts"

  resource_group_name = module.resource_group.resource_group_name

  postgres_id = module.postgres.server_id

  action_group_id = module.action_group.id
}

module "dns" {

  source = "./modules/dns"

  dns_zone_name = local.current_env.domain_name

  resource_group_name = module.resource_group.resource_group_name
}

module "edge" {

  count = var.environment == "prod" ? 1 : 0

  source = "./modules/edge"

  resource_group_name = module.resource_group.resource_group_name

  location = var.location

  agw_subnet_id = module.networking.subnet_ids["AGWSubnet"]

  tags = local.tags
}

resource "azurerm_network_security_rule" "agw_gateway_manager" {

  count = var.environment == "prod" ? 1 : 0

  name = "Allow-GatewayManager"

  priority = 100

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_ranges = [
    "65200-65535"
  ]

  source_address_prefix = "GatewayManager"

  destination_address_prefix = "*"

  resource_group_name = module.resource_group.resource_group_name

  network_security_group_name = "NSG-PROD-AGW"
}

resource "azurerm_network_security_rule" "agw_azure_lb" {

  count = var.environment == "prod" ? 1 : 0

  name = "Allow-AzureLoadBalancer"

  priority = 110

  direction = "Inbound"

  access = "Allow"

  protocol = "*"

  source_port_range = "*"

  destination_port_range = "*"

  source_address_prefix = "AzureLoadBalancer"

  destination_address_prefix = "*"

  resource_group_name = module.resource_group.resource_group_name

  network_security_group_name = "NSG-PROD-AGW"
}

resource "azurerm_network_security_rule" "agw_http_https" {

  count = var.environment == "prod" ? 1 : 0

  name = "Allow-Internet-Web"

  priority = 120

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_ranges = [
    "80",
    "443"
  ]

  source_address_prefix = "Internet"

  destination_address_prefix = "*"

  resource_group_name = module.resource_group.resource_group_name

  network_security_group_name = "NSG-PROD-AGW"
}

resource "azurerm_cdn_frontdoor_profile" "this" {

  count = var.environment == "prod" ? 1 : 0

  name = "afd-ctmp"

  resource_group_name = module.resource_group.resource_group_name

  sku_name = "Premium_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {

  count = var.environment == "prod" ? 1 : 0

  name = "ctmp"

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {

  count = var.environment == "prod" ? 1 : 0

  name = "agw-origin-group"

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id

  load_balancing {}

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {

  count = var.environment == "prod" ? 1 : 0

  name = "application-gateway"

  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[0].id

  host_name = module.edge[0].agw_fqdn

  certificate_name_check_enabled = false
}

resource "azurerm_cdn_frontdoor_route" "this" {

  count = var.environment == "prod" ? 1 : 0

  name = "default-route"

  cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.this[0].id

  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[0].id

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.this[0].id
  ]

  patterns_to_match = ["/*"]

  supported_protocols = [
    "Http",
    "Https"
  ]

  forwarding_protocol = "MatchRequest"
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.this,
    azurerm_cdn_frontdoor_origin.this
  ]
}

resource "azurerm_static_web_app" "frontend" {

  count = var.environment == "prod" ? 1 : 0

  name = "swa-ctmp-prod"

  resource_group_name = module.resource_group.resource_group_name

  location = "East Asia"

  sku_tier = "Standard"

  sku_size = "Standard"
}

resource "azurerm_role_assignment" "containerapps_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_apps.principal_id
}

resource "azurerm_container_app" "api_gateway" {
  name                         = "ca-api-gateway-${var.environment}"
  container_app_environment_id = module.container_apps_environment.id
  resource_group_name          = module.resource_group.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  registry {
    server   = module.acr.login_server
    identity = azurerm_user_assigned_identity.container_apps.id
  }

  ingress {
    external_enabled = false
    target_port      = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "api-gateway"
      image  = "${module.acr.login_server}/ctmp/api-gateway:${var.container_image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "NODE_ENV"
        value = var.environment
      }

      env {
        name  = "PORT"
        value = "3000"
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.containerapps_acr_pull
  ]
}

resource "azurerm_container_app" "frontend" {
  name                         = "ca-frontend-${var.environment}"
  container_app_environment_id = module.container_apps_environment.id
  resource_group_name          = module.resource_group.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  registry {
    server   = module.acr.login_server
    identity = azurerm_user_assigned_identity.container_apps.id
  }

  ingress {
    external_enabled = false
    target_port      = 80

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "frontend"
      image  = "${module.acr.login_server}/ctmp/frontend:${var.container_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  depends_on = [
    azurerm_role_assignment.containerapps_acr_pull
  ]
}
