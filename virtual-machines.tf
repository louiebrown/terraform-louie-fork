## Create Bastion Host
resource "azurerm_public_ip" "bastion" {
  name                = "${var.team_name}-bastion-public-ip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"

  tags = {
    team = var.team_name
  }
}

resource "azurerm_bastion_host" "this" {
  name                = "${var.team_name}-bastion"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tunneling_enabled   = true
  sku                 = "Standard"

  ip_configuration {
    name                 = "${var.team_name}-bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}



## Create Private VMs

# Create Private NICs
resource "azurerm_network_interface" "private" {
  count               = 2
  name                = "${var.team_name}-private-vm-${count.index}-nic"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  ip_configuration {
    name                          = "${var.team_name}-nic-config"
    subnet_id                     = azurerm_subnet.private[count.index].id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = {
    team = var.team_name
  }
}

# Create Private VM
resource "azurerm_linux_virtual_machine" "private" {
  count               = 2
  name                = "${var.team_name}-private-vm-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.private[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_source.publisher
    offer     = var.vm_source.offer
    sku       = var.vm_source.sku
    version   = var.vm_source.version
  }

  tags = {
    team = var.team_name
  }
}

# Enable virtual machine extension and install Nginx
resource "azurerm_virtual_machine_extension" "my_vm_extension" {
  count                = 2
  name                 = "Nginx"
  virtual_machine_id   = azurerm_linux_virtual_machine.private[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt-get update && sudo apt-get install nginx -y && echo \"Hello World from $(hostname)\" > /var/www/html/index.html && sudo systemctl restart nginx"
 }
SETTINGS

}