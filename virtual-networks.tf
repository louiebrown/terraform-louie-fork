## Create Virtual Networks

# Create Public VNet
resource "azurerm_virtual_network" "public" {
  name                = "${var.team_name}-public-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = [var.public_vnet_cidr]

  tags = {
    team = var.team_name
  }
}
resource "azurerm_subnet" "public" {
  count                = 2
  name                 = "${var.team_name}-public-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = [var.public_subnet_cidrs[count.index]]
}
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = [var.bastion_cidr]
}


# Create Private VNet
resource "azurerm_virtual_network" "private" {
  name                = "${var.team_name}-private-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = [var.private_vnet_cidr]

  tags = {
    team = var.team_name
  }
}
resource "azurerm_subnet" "private" {
  count                = 2
  name                 = "${var.team_name}-private-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = [var.private_subnet_cidrs[count.index]]
}
# Create Private Security Group
resource "azurerm_network_security_group" "private" {
  name                = "${var.team_name}-private-nsg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  security_rule {
    name                       = "PublicToPrivate"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.public_vnet_cidr
    destination_address_prefix = var.private_vnet_cidr
  }
  security_rule {
    name                       = "web"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = var.private_vnet_cidr
  }

  tags = {
    team = var.team_name
  }
}
# Associate the Network Security Group to the subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  count                     = 2
  subnet_id                 = azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.private.id
}



# Ceate VNet Peering
resource "azurerm_virtual_network_peering" "public-to-private" {
  name                      = "${var.team_name}-public-to-private-peering"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.public.name
  remote_virtual_network_id = azurerm_virtual_network.private.id
}

resource "azurerm_virtual_network_peering" "private-to-public" {
  name                      = "${var.team_name}-private-to-public-peering"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.private.name
  remote_virtual_network_id = azurerm_virtual_network.public.id
}