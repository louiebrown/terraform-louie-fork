terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "louie-terraform-rg"
    storage_account_name = "louieterraformsa"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Virtual Network
resource "azurerm_virtual_network" "lb_vnet" {
  name                = "lb-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Private Subnets (2 for HA)
resource "azurerm_subnet" "lb_private_subnet" {
  count                = 2
  name                 = "lb-private-subnet-${count.index}"
  resource_group_name  = azurerm_virtual_network.lb_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.lb_vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "lb_nsg" {
  name                = "lb-nsg"
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
}

# Network Interfaces
resource "azurerm_network_interface" "lb_nic" {
  count               = 2
  name                = "lb-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.lb_private_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machines (2 for HA)
resource "azurerm_linux_virtual_machine" "lb_vm" {
  count               = 2
  name                = "lb-vm-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_private_key)
  }

  network_interface_ids = [azurerm_network_interface.lb_nic[count.index].id]

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

# Azure Load Balancer
resource "azurerm_lb" "lb" {
  name                = "lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackendPool"
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
}

# Azure Database (PostgreSQL)
resource "azurerm_postgresql_flexible_server" "db" {
  name                         = "academy-db"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku_name                     = "GP_Standard_D2s_v3"
  storage_mb                   = 32768
  administrator_login          = "adminuser"
  administrator_password       = "StrongPassword1234!"
  geo_redundant_backup_enabled = true
}

# Azure Key Vault (SSL Certificates)
resource "azurerm_key_vault" "kv" {
  name                = "academy-kv"
  tenant_id           = var.tenant_id
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "standard"
}

resource "azurerm_key_vault_certificate" "ssl_cert" {
  name         = "ssl-cert"
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_type   = "RSA"
      key_size   = 2048
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pem-file"
    }


    x509_certificate_properties {
      subject            = "CN=example.com"
      validity_in_months = 12

      key_usage = [
        "digitalSignature",
        "keyEncipherment"
      ]

      extended_key_usage = [
        "1.3.6.1.5.5.7.3.1", # TLS Server Authentication
        "1.3.6.1.5.5.7.3.2"  # TLS Client Authentication
      ]
    }
  }
}

