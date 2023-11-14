output "id" {
  value       = azurerm_resource_group.resource_group.id
  description = "The resource group ID."
}
output "name" {
  value       = azurerm_resource_group.resource_group.name
  description = "The resource group name."
}