variable "managed_environments_name" {
  description = "The managed environment name to deploy."
  type        = string
}
variable "log_analytics_workspace_id" {
  description = "The log analytics workspace id to connect."
  type        = string
}
variable "vnet_id" {
  description = "The vnet id to connect."
  type        = string
}
variable "subnet_id" {
  description = "The subnet id to connect."
  type        = string
}
variable "location" {
  description = "The location to deploy to."
}
variable "resource_group_name" {
  description = "The resource group name to deploy to."
  type        = string
}
variable "resource_group_id" {
  description = "The resource group id to deploy to."
  type        = string
}
variable "common_tags" {
  description = "The tags to be added to all resources."
}
