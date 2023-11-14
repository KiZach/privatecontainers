output "id" {
  value       = azurerm_virtual_network.virtual_network.id
  description = "The vrirtual network ID."
}
output "name" {
  value       = azurerm_virtual_network.virtual_network.name
  description = "The vrirtual network name."
}
output "resource_group_name" {
  value       = azurerm_virtual_network.virtual_network.resource_group_name
  description = "The vrirtual network resource group."
}