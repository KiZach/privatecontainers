variable "container_app_name" {
  description = "The managed app name to deploy."
  type        = string
}
variable container_app_image {
  description = "The managed app image url to deploy."
  type        = string
}
variable container_app_port {
  description = "The managed app port."
  type        = number
}
variable "container_app_envs" {
  type        = list(map(string))
  description = "List of objects that represent the container app environment values."
  # container_app_envs = [{ name = "", value = "" }]
}
variable "container_app_managed_environment_id" {
  description = "The managed app environment id to connect."
  type        = string
}
variable "container_app_managed_environment_zone_name" {
  description = "The managed app environment dns zone name."
  type        = string
}
variable "container_app_managed_environment_static_ip_address" {
  description = "The managed app environment satic ip address."
  type        = string
}
variable "resource_group_name" {
  description = "The resource group name to deploy to."
  type        = string
}
variable "common_tags" {
  description = "The tags to be added to all resources."
}
