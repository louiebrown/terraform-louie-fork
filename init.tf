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
  name                = "lb-public-subnet-${count.index}" # increment for each snet
  resource_group_name = azurerm_virtual_network.lb_public_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.lb_public_vnet.name
  address_prefixes    = ["10.0.${count.index}.0/24"]
}

# Network Security Group for Public Subnet
resource "azurerm_network_security_group" "lb_public_nsg" {
  name                = "lb-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    team = "louie-terraform"
  }

  # Allow SSH (Port 22)
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

  # Allow HTTP (Port 80)
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

  # Allow HTTPS (Port 443)
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

# Public IPs for VMs
resource "azurerm_public_ip" "lb_public_ip" {
  count               = 3
  name                = "lb-public-ip-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = {
    team = "louie-terraform"
  }
}

# Network Interface with Public IP
resource "azurerm_network_interface" "lb_public_nic" {
  count               = 3
  name                = "lb-public-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.lb_public_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lb_public_ip[count.index].id
  }

  tags = {
    team = "louie-terraform"
  }
}

# Virtual Machines in Public Subnets
resource "azurerm_linux_virtual_machine" "lb_public_vm" {
  count               = 3
  name                = "lb-public-vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ms"

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_private_key
  }


  network_interface_ids = [
    azurerm_network_interface.lb_public_nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Network Interface for Private Subnets
resource "azurerm_network_interface" "lb_private_nic" {
  count               = 3
  name                = "lb-private-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.lb_private_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    team = "louie-terraform"
  }
}

# Virtual Machines in Private Subnets
resource "azurerm_linux_virtual_machine" "lb_private_vm" {
  count               = 3
  name                = "lb-private-vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ms"

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_private_key
  }

  network_interface_ids = [
    azurerm_network_interface.lb_private_nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  tags = {
    team = "louie-terraform"
  }
}

# Allow traffic from Public Subnet to Private Subnet
resource "azurerm_network_security_group" "lb_private_nsg" {
  name                = "lb-private-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-Private-to-Public"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16" # Address space of public VNet
    destination_address_prefix = "10.1.0.0/16" # Address space of private VNet
  }
  tags = {
    team = "louie-terraform"
  }
}

# Bastion Subnet
resource "azurerm_subnet" "lb_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = ["10.0.255.0/27"]
  virtual_network_name = azurerm_virtual_network.lb_public_vnet.name
  resource_group_name  = var.resource_group_name
}

# Public IP for Bastion Host
resource "azurerm_public_ip" "lb_bastion_public_ip" {
  name                = "lb-bastion-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# Bastion Host
resource "azurerm_bastion_host" "lb_bastion_host" {
  name                = "lb-bastion-host"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                 = "lb-bastion-configuration"
    subnet_id            = azurerm_subnet.lb_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.lb_bastion_public_ip.id
  }
}



