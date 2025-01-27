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

  subscription_id = var.subscription_id
  }

# Public VNET
resource "azurerm_virtual_network" "lb_public_vnet" {
  name                = "lb-public-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    team = "louie-terraform"
  }
}

# Public Subnet x 3
resource "azurerm_subnet" "lb_public_subnet" {
  count               = 3
  name                = "lb-public-subnet-${count.index}"
  resource_group_name = azurerm_virtual_network.lb_public_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.lb_public_vnet.name
  address_prefixes    = ["10.0.${count.index}.0/24"]
}

# Private VNET
resource "azurerm_virtual_network" "lb_private_vnet" {
  name                = "lb-private-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    team = "louie-terraform"
  }
}

# Private Subnet x 3
resource "azurerm_subnet" "lb_private_subnet" {
  count               = 3
  name                = "lb-private-subnet-${count.index}"
  resource_group_name = azurerm_virtual_network.lb_private_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.lb_private_vnet.name
  address_prefixes    = ["10.1.${count.index}.0/24"]
}