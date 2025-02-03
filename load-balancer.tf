# Create Public IP for Load Balancer
resource "azurerm_public_ip" "load_balacer" {
  name                = "${var.team_name}-lb-public-ip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    team = var.team_name
  }
}

# Create Public Load Balancer
resource "azurerm_lb" "this" {
  name                = "${var.team_name}-lb"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.team_name}-lb-ip"
    public_ip_address_id = azurerm_public_ip.load_balacer.id
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = "${var.team_name}-lb-be-ap"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "test-probe"
  port            = 80
}

resource "azurerm_lb_rule" "this" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "test-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.this.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
}

resource "azurerm_lb_outbound_rule" "this" {
  name                    = "test-outbound"
  loadbalancer_id         = azurerm_lb.this.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id

  frontend_ip_configuration {
    name = azurerm_lb.this.frontend_ip_configuration[0].name
  }
}

# Associate Network Interface to the Backend Pool of the Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "this" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.private[count.index].id
  ip_configuration_name   = azurerm_network_interface.private[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
}