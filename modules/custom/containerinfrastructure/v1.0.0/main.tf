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
  subnet_address_prefixes = ["10.0.8.0/24"]
  subnet_virtual_network_name = module.virtual_network.name
  resource_group_name = module.virtual_network.resource_group_name
}

module "subnet_containerapps" {
  source = "../../../common/azurerm_subnet/v1.0.0"
  subnet_name = "containerapps"
  subnet_address_prefixes = ["10.0.0.0/21"]
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

module "log_analytics_workspace" {
  source = "../../../common/azurerm_log_analytics_workspace/v1.0.0"
  log_analytics_workspace_name = "la-${random_string.deployment_string.result}"
  resource_group_name = module.resource_group.name
  location = var.location
  common_tags = var.common_tags
}

module "managed_environment" {
  source = "../../../common/azurerm_container_app_environment/v1.0.0"
  managed_environments_name = "acae-${random_string.deployment_string.result}"
  log_analytics_workspace_id = module.log_analytics_workspace.id
  vnet_id = module.virtual_network.id
  subnet_id = module.subnet_containerapps.id
  resource_group_name = module.resource_group.name
  resource_group_id = module.resource_group.id
  location = var.location
  common_tags = var.common_tags
}

module "managed_app_allure_docker_ui_service" {
  source = "../../../common/azurerm_container_app/v1.0.0"
  container_app_name = "app1-${random_string.deployment_string.result}"
  container_app_image = "docker.io/frankescobar/allure-docker-service-ui:latest"
  container_app_port = 5252
  container_app_envs = [
    { name = "ALLURE_DOCKER_PUBLIC_API_URL", value = "http://${module.public_ip_application_gateway.ip_address}" },
    { name = "ALLURE_DOCKER_PUBLIC_API_URL_PREFIX", value = "/api" }
  ]
  container_app_managed_environment_id = module.managed_environment.id
  container_app_managed_environment_static_ip_address = module.managed_environment.static_ip_address
  container_app_managed_environment_zone_name = module.managed_environment.private_dns_zone_name
  resource_group_name = module.resource_group.name
  common_tags = var.common_tags
}

module "managed_app_allure_docker_service" {
  source = "../../../common/azurerm_container_app/v1.0.0"
  container_app_name = "app2-${random_string.deployment_string.result}"
  container_app_image = "docker.io/frankescobar/allure-docker-service:latest"
  container_app_port = 5050
  container_app_envs = [
    { name = "CHECK_RESULTS_EVERY_SECONDS", value = "NONE" },
    { name = "KEEP_HISTORY", value = 1 },
    { name = "KEEP_HISTORY_LATEST", value = 25},
    { name = "SECURITY_USER", value = "admin" },
    { name = "SECURITY_PASS", value = "password" },
    { name = "SECURITY_ENABLED", value = 1 },
    { name = "MAKE_VIEWER_ENDPOINTS_PUBLIC", value = 1 },
    { name = "URL_PREFIX", value = "/api" },
    { name = "SERVER_URL", value = "http://${module.public_ip_application_gateway.ip_address}" },
  ]
  container_app_managed_environment_id = module.managed_environment.id
  container_app_managed_environment_static_ip_address = module.managed_environment.static_ip_address
  container_app_managed_environment_zone_name = module.managed_environment.private_dns_zone_name
  resource_group_name = module.resource_group.name
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
  frontend_ip_configuration = { public_ip_address_id = module.public_ip_application_gateway.id, private_ip_address = "10.0.8.10", private_ip_address_allocation = "Static" }
  http_listeners        = [
    { name = "allure-http-listener", frontend_ip_configuration = "Public", port = 80, protocol = "Http" }
  ]
  backend_address_pools = [
    { name = "${module.managed_app_allure_docker_ui_service.name}-backend-pool", fqdns = "${module.managed_app_allure_docker_ui_service.name}.${module.managed_environment.private_dns_zone_name}" },
    { name = "${module.managed_app_allure_docker_service.name}-backend-pool", fqdns = "${module.managed_app_allure_docker_service.name}.${module.managed_environment.private_dns_zone_name}" }
  ]

  backend_http_settings = [
    { name = "${module.managed_app_allure_docker_ui_service.name}-backend-https-setting", port = 443, protocol = "Https", path = "/", request_timeout = 20, pick_host_name_from_backend_address = true },
    { name = "${module.managed_app_allure_docker_service.name}-backend-https-setting", port = 443, protocol = "Https", path = "/", request_timeout = 20, pick_host_name_from_backend_address = true }
  ]
  request_routing_rules = [
    {
      name                       = "allure-request-routing-rule"
      priority                   = 10
      http_listener_name         = "allure-http-listener"
      url_path_map_name          = "allure-request-routing-rules"
    }
  ]
  url_path_maps = [
    {
      name = "allure-request-routing-rules"
      default_backend_address_pool_name   = "${module.managed_app_allure_docker_ui_service.name}-backend-pool"
      default_backend_http_settings_name  = "${module.managed_app_allure_docker_ui_service.name}-backend-https-setting"
    }
  ]
  url_path_map_path_rules = [
    {
      url_path_map_name           = "allure-request-routing-rules"
      name                        = "${module.managed_app_allure_docker_service.name}"
      path                        = "/api*"
      backend_address_pool_name   = "${module.managed_app_allure_docker_service.name}-backend-pool"
      backend_http_settings_name  = "${module.managed_app_allure_docker_service.name}-backend-https-setting"
    }
  ]
}


