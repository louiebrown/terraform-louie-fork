terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "louie-terraform-rg"
    storage_account_name = "louieterraformsa"
    container_name = "terraform-state"
    key = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
  subscription_id = "d38fa016-777f-4647-bbc8-0aaf1933103c"
}

