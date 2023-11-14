resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.common_tags
}
