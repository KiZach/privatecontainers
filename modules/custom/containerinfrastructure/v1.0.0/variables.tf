variable "subscription_id" {
  description = "The subscription id to deploy to."
  type        = string
}
variable "resource_group_name" {
  description = "The resource group name to deploy to."
  type        = string
}
variable "location" {
  description = "The location to deploy to."
}
variable "common_tags" {
  description = "The tags to be added to all resources."
}