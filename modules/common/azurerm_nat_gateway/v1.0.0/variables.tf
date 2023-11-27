variable "nat_gateway_name" {
  description = "The nat gateway name to deploy."
  type        = string
}
variable "nat_gateway_sku" {
  description = "The net gateway sku."
  type        = string
  default = "Standard"
}
variable "location" {
  description = "The location to deploy to."
}
variable "resource_group_name" {
  description = "The resource group name to deploy to."
  type        = string
}
variable "common_tags" {
  description = "The tags to be added to all resources."
}
