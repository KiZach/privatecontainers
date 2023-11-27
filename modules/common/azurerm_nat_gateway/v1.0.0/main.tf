resource "azurerm_nat_gateway" "nat_gateway" {
  name                = var.nat_gateway_name
  sku_name            = var.nat_gateway_sku
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.common_tags
}