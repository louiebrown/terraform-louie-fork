# Public VNET
resource "azurerm_virtual_network" "lb_public_vnet" {
  name                = "${var.env_prefix}-public-vnet"  # Dynamic name based on environment
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    team = "louie-terraform"
    environment = var.environment  # Adds environment tag
  }
}

# Private VNET
resource "azurerm_virtual_network" "lb_private_vnet" {
  name                = "${var.env_prefix}-private-vnet"  # Dynamic name based on environment
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    team = "louie-terraform"
    environment = var.environment  # Adds environment tag
  }
}

# Public Subnet x 2 (for Dev and Prod environments)
resource "azurerm_subnet" "lb_public_subnet" {
  count               = 2  # Change count to 2 for both environments
  name                = "${var.env_prefix}-public-subnet-${count.index}"
  resource_group_name = azurerm_virtual_network.lb_public_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.lb_public_vnet.name
  address_prefixes    = ["10.0.${count.index}.0/24"]
}

# Private Subnet x 2 (for Dev and Prod environments)
resource "azurerm_subnet" "lb_private_subnet" {
  count               = 2  # Change count to 2 for both environments
  name                = "${var.env_prefix}-private-subnet-${count.index}"
  resource_group_name = azurerm_virtual_network.lb_private_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.lb_private_vnet.name
  address_prefixes    = ["10.1.${count.index}.0/24"]
}
