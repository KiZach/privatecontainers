resource "azurerm_container_app_environment" "container_app_environment" {
  name = var.managed_environments_name
  resource_group_name = var.resource_group_name
  location = var.location
  tags = var.common_tags
  internal_load_balancer_enabled = true
  infrastructure_subnet_id = var.subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  timeouts {
    create = "4h"
  }
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = azurerm_container_app_environment.container_app_environment.default_domain
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "containerapplink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.vnet_id
  tags                  = var.common_tags
}
