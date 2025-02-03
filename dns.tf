# Create a DNS Zone in Azure
resource "azurerm_dns_zone" "dns_zone" {
  name                = "lb-pa-task.com"
  resource_group_name = var.resource_group_name
}

# Create an A Record to point to the Load Balancer's public IP
resource "azurerm_dns_a_record" "load_balancer_a_record" {
  name                = "www"  # Pointing www to the load balancer
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.lb_public_ip.ip_address]  # Point to the Load Balancer's public IP

  tags = {
    environment = var.environment
  }
}
