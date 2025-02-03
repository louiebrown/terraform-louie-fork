resource "azurerm_dns_ns_record" "bancey" {
  name                = var.team_name
  zone_name           = "azure.lab.bancey.xyz"
  resource_group_name = "dns-zones"
  ttl                 = var.dns_ttl
  records             = azurerm_dns_zone.this.name_servers
  tags = {
    team = var.team_name
  }
}

resource "azurerm_dns_zone" "this" {
  name                = "${var.team_name}.azure.lab.bancey.xyz"
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    team = var.team_name
  }
}

resource "azurerm_dns_a_record" "apex" {
  name                = "@"
  resource_group_name = azurerm_resource_group.this.name
  zone_name           = azurerm_dns_zone.this.name
  ttl                 = var.dns_ttl
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.this.id
}

resource "azurerm_dns_txt_record" "domain_validation" {
  name                = "_dnsauth"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.this.validation_token
  }
}