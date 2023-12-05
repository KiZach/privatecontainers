output "id" {
  value       = azurerm_container_app_environment.container_app_environment.id
  description = "The managed environment ID."
}
output "static_ip_address" {
  value       = azurerm_container_app_environment.container_app_environment.static_ip_address
  description = "The managed environment static ip address."
}
output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.private_dns_zone.name  
}
