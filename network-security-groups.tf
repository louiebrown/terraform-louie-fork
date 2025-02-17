# Allow HTTP, HTTPS, and SSH (port 22) for the public subnet
resource "azurerm_network_security_group" "lb_public_nsg" {
  name                = "${var.env_prefix}-lb-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Attach NSG to Each Public Subnet
resource "azurerm_subnet_network_security_group_association" "lb_public_nsg_association" {
  count                      = 3
  subnet_id                  = azurerm_subnet.lb_public_subnet[count.index].id
  network_security_group_id  = azurerm_network_security_group.lb_public_nsg.id
}


# NSG for Private Subnet
resource "azurerm_network_security_group" "lb_private_nsg" {
  name                = "lb-private-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-private"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.0.0/16"  # Public subnet CIDR range
    destination_address_prefix = "*"
  }

  # Allow SSH from Public to Private (for VM Bastion/Management)
  security_rule {
    name                       = "allow-ssh-from-public"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"  # SSH
    source_address_prefix      = "10.1.0.0/16"  # Public subnet CIDR range
    destination_address_prefix = "*"
  }

  tags = {
    team = "louie-terraform"
  }
}

# Attach NSG to Each Public Subnet
resource "azurerm_subnet_network_security_group_association" "lb_private_nsg_association" {
  count                      = 3
  subnet_id                  = azurerm_subnet.lb_private_subnet[count.index].id
  network_security_group_id  = azurerm_network_security_group.lb_private_nsg.id
}