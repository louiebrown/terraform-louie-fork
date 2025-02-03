variable "location" {
  description = "The Azure location where resources will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure resource group."
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type      = string
  sensitive = true
}

variable "object_id" {

description = "The Azure Terraform SP ID."

type = string

sensitive = true

}