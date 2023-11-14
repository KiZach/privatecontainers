variable "public_ip_name" {
  description = "The resource group name to deploy to."
  type        = string
}
variable "public_ip_allocation_method" {
  description = "The public ip allocation method."
  type        = string
  default = "Static"
}
variable "public_ip_sku" {
  description = "The public ip sku."
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
