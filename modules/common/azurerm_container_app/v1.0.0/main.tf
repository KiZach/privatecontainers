resource "azurerm_container_app" "app" {
  name                         = var.container_app_name
  container_app_environment_id = var.container_app_managed_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.container_app_name
      image  = var.container_app_image
      cpu    = 0.25
      memory = "0.5Gi"
      dynamic "env" {
        for_each = var.container_app_envs
        content {
          name = env.value.name
          value = env.value.value
        }
      }
    }
    min_replicas = 1
    max_replicas = 1
  }
  
  ingress {
    target_port = var.container_app_port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled  = true
  }
  
  
}

resource "azurerm_private_dns_a_record" "containerapp_record" {
  name                = azurerm_container_app.app.name
  zone_name           = var.container_app_managed_environment_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.container_app_managed_environment_static_ip_address]
}
