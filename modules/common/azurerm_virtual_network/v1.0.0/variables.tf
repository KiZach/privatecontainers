variable "virtual_network_name" {
  description = "The resource group name to deploy to."
  type        = string
}
variable "virtual_network_address_space" {
  description = "List of all virtual network addresses"
  type        = list(string)
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
