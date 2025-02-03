# Declare environment prefix variable
variable "env_prefix" {
  description = "Prefix for environment-specific resource names"
  type        = string
}

# Declare the environment type (Dev or Prod)
variable "environment" {
  description = "The environment (Dev or Prod)"
  type        = string
}

# Declare location for the resources
variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

# Declare the resource group name
variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

# Declare the number of VMs to create
variable "vms_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

# Declare the SSH public key path
variable "ssh_private_key" {
  description = "Path to the SSH private key file"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}
variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
  sensitive   = true
}

variable "object_id" {
  description = "The Azure Terraform SP ID."
  type = string
  sensitive = true
}
