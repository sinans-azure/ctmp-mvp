output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "agw_fqdn" {
  value = azurerm_public_ip.this.ip_address
}