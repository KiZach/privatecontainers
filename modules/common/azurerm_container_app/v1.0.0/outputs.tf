output "id" {
  value       = azurerm_container_app.app.id
  description = "The managed app ID."
}
output "name" {
  value       = azurerm_container_app.app.name
  description = "The managed app name."
}