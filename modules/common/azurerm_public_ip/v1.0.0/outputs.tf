output "id" {
  value       = azurerm_public_ip.public_ip.id
  description = "The public IP ID."
}
output "ip_address" {
  value       = azurerm_public_ip.public_ip.ip_address
  description = "The public IP address."
}
