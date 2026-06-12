output "principal_id" {
  value = azurerm_linux_function_app.this.identity[0].principal_id
}

output "name" {
  value = azurerm_linux_function_app.this.name
}