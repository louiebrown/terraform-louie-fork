# Create a PostgreSQL server
resource "azurerm_postgresql_server" "lb_postgresql_server" {
  name                = "${var.env_prefix}-postgresql-server"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "11" 
  sku_name            = "B_Gen5_2" 
  administrator_login = "psqladmin"

  ssl_enforcement_enabled = true  # Enforce SSL connections to the database

  geo_redundant_backup_enabled = true  # Enable geo-redundant backups for high availability

  tags = {
    environment = var.environment
  }
}

# Create a virtual network rule to allow access from the VNet (Private Subnet)
resource "azurerm_postgresql_virtual_network_rule" "lb_pg_vnet_rule" {
  name                      = "allow-vnet"
  resource_group_name       = var.resource_group_name
  server_name               = azurerm_postgresql_server.lb_postgresql_server.name
  subnet_id = azurerm_subnet.lb_private_subnet[0].id  # Reference the subnet ID of the private subnet
}