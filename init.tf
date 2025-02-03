terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "louie-terraform-rg"
    storage_account_name = "louieterraformsa"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }

    required_version = "1.10.5"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "this" {
  name     = "${var.team_name}-tf-rg"
  location = var.location
}