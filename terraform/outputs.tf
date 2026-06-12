output "environment" {
  value = var.environment
}

output "vnet_name" {
  value = module.networking.vnet_name
}

output "subnet_ids" {
  value = module.networking.subnet_ids
}

output "nsg_names" {
  value = {
    for k, v in module.nsgs :
    k => v.name
  }
}

output "postgres_fqdn" {
  value = module.postgres.fqdn
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "keyvault_name" {
  value = module.keyvault.name
}

output "dns_name_servers" {
  value = module.dns.name_servers
}

output "agw_public_ip" {

  value = try(module.edge[0].public_ip, null)
}

output "static_web_app_url" {

  value = try(
    azurerm_static_web_app.frontend[0].default_host_name,
    null
  )
}

output "api_gateway_fqdn" {
  value = azurerm_container_app.api_gateway.ingress[0].fqdn
}

output "frontend_fqdn" {
  value = azurerm_container_app.frontend.ingress[0].fqdn
}
