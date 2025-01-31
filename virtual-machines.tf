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
}

# Network Interface with Private IP
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
