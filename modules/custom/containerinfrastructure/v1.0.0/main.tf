data "azurerm_client_config" "current" {}

resource "random_string" "deployment_string" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
  keepers = {
    resource_group = var.resource_group_name
  }
}

module "resource_group" {
  source = "../../../common/azurerm_resource_group/v1.0.0"
  resource_group_name = var.resource_group_name
  location = var.location
  common_tags = var.common_tags
}

module "virtual_network" {
  source = "../../../common/azurerm_virtual_network/v1.0.0"
  virtual_network_name = "vnet-${random_string.deployment_string.result}"
  virtual_network_address_space = ["10.0.0.0/16"]
  resource_group_name = module.resource_group.name
  location = var.location
  common_tags = var.common_tags
}

module "subnet_applicationgateway" {
  source = "../../../common/azurerm_subnet/v1.0.0"
  subnet_name = "applicationgateway"
  subnet_address_prefixes = ["10.0.0.0/24"]
  subnet_virtual_network_name = module.virtual_network.name
  resource_group_name = module.virtual_network.resource_group_name
}

module "subnet_containerapps" {
  source = "../../../common/azurerm_subnet/v1.0.0"
  subnet_name = "containerapps"
  subnet_address_prefixes = ["10.0.1.0/24"]
  subnet_virtual_network_name = module.virtual_network.name
  resource_group_name = module.virtual_network.resource_group_name
  depends_on = [ module.subnet_applicationgateway ]
}

module "public_ip_application_gateway" {
  source = "../../../common/azurerm_public_ip/v1.0.0"
  public_ip_name = "pip-agw-${random_string.deployment_string.result}"
  resource_group_name = module.resource_group.name
  location = var.location
  common_tags = var.common_tags
}

module "application_gateway" {
  source = "../../../public/terraform-azurerm-application-gateway/v1.2.1"
  name                      = "agw-${random_string.deployment_string.result}"
  resource_group_name       = module.resource_group.name
  location                  = var.location
  tags                      = var.common_tags
  sku                       = { tier = "WAF_v2", size = "WAF_v2" }
  autoscale_configuration   = { min_capacity = 1, max_capacity = 2 }
  waf_configuration         = { enabled = true, firewall_mode = "Detection", rule_set_version = "3.0"}
  subnet_id                 = module.subnet_applicationgateway.id
  frontend_ip_configuration = { public_ip_address_id = module.public_ip_application_gateway.id, private_ip_address = "10.0.0.10", private_ip_address_allocation = "Static" }
  backend_address_pools = [
    { name = "backend-address-pool-1", ip_addresses = "10.0.0.4,10.0.0.5,10.0.0.6" }
  ]
  http_listeners        = [{ name = "http-listener", frontend_ip_configuration = "Public", port = 80, protocol = "Http" }]
  backend_http_settings = [{ name = "backend-http-setting", port = 80, protocol = "Http", request_timeout = 20 }]
  request_routing_rules = [
    {
      name                       = "request-routing-rule-1"
      priority                   = 10
      http_listener_name         = "http-listener"
      backend_address_pool_name  = "backend-address-pool-1"
      backend_http_settings_name = "backend-http-setting"
    }
  ]
}

module "public_ip_nat_gateway" {
  source = "../../../common/azurerm_public_ip/v1.0.0"
  public_ip_name = "pip-natg-${random_string.deployment_string.result}"
  resource_group_name = module.resource_group.name
  location = var.location
  common_tags = var.common_tags
}

module "nat_gateway" {
  source = "../../../common/azurerm_nat_gateway/v1.0.0"
  nat_gateway_name = "natg-${random_string.deployment_string.result}"
  resource_group_name = module.resource_group.name
  location = var.location
  common_tags = var.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway" {
  nat_gateway_id       = module.nat_gateway.id
  public_ip_address_id = module.public_ip_nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_gateway_subnet_containerapps" {
  subnet_id      = module.subnet_containerapps.id
  nat_gateway_id = module.nat_gateway.id
}

module "log_analytics_workspace" {
  source = "../../../common/azurerm_log_analytics_workspace/v1.0.0"
  log_analytics_workspace_name = "la-${random_string.deployment_string.result}"
  resource_group_name = module.resource_group.name
  location = var.location
  common_tags = var.common_tags
}