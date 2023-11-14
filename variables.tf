variable "location" {
  description = "Deployment location"
  default = "westeurope"
}
variable "common_tags" {
  description = "The tags to be added to all resources."
  default     = {
    deployedby   = "Terraform IaC"
  }
}
