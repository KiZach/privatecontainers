module "sampleapp" {
  source = "./modules/custom/containerinfrastructure/v1.0.0"
  subscription_id = "4900d9ad-3740-49ee-8e3f-75dba81a55d6"
  resource_group_name = "appl-test-containerapp-westeurope"
  location = var.location
  common_tags = var.common_tags
}
