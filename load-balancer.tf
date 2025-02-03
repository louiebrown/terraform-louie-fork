resource "azurerm_lb" "public_lb" {
  name                = "${var.env_prefix}-loadbalancer"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "loadbalancer-ip"
    public_ip_address_id = azurerm_public_ip.lb_public_ip[0].id  # Reference public IP for frontend
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "${var.env_prefix}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"  # Make sure the IP is static for the load balancer
  tags = {
    environment = var.environment
  }
}

resource "azurerm_lb_backend_address_pool" "public_lb_backend" {
  name                = "${var.env_prefix}-backend-pool"
  loadbalancer_id     = azurerm_lb.public_lb.id  # Attach it to the load balancer
}

resource "azurerm_lb_probe" "http_probe" {
  name                = "${var.env_prefix}-http-probe"
  loadbalancer_id     = azurerm_lb.public_lb.id
  port                = 80
  protocol            = "Http"
  request_path        = "/"  # Simple request path for the probe
}

resource "azurerm_lb_rule" "http_rule" {
  name                            = "${var.env_prefix}-http-rule"
  loadbalancer_id                 = azurerm_lb.public_lb.id
  frontend_ip_configuration_name  = azurerm_lb.frontend_ip_configuration[0].name  # Corrected reference
  probe_id                       = azurerm_lb_probe.http_probe.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
}


resource "azurerm_network_interface_backend_address_pool_association" "public_nic_backend_pool_association" {
  count                     = var.vms_count
  network_interface_id      = azurerm_network_interface.lb_public_nic[count.index].id
  backend_address_pool_id   = azurerm_lb_backend_address_pool.public_lb_backend.id
  ip_configuration_name     = azurerm_network_interface.lb_public_nic[count.index].ip_configuration[0].name
}

resource "azurerm_network_security_group" "lb_public_nsg" {
  name                = "${var.env_prefix}-lb-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}
