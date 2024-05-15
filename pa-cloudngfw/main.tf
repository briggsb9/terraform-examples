resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.resource_prefix}-${var.resource_suffix}"
  location = var.location
}

resource "azurerm_public_ip" "public_ip" {
  name                = "pip-${var.resource_prefix}-${var.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.resource_prefix}-${var.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.resource_prefix}-${var.resource_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "trust_subnet" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_trust

  delegation {
    name = "trusted"

    service_delegation {
      name    = "PaloAltoNetworks.Cloudngfw/firewalls"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "trust_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.trust_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "untrust_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_untrust

  delegation {
    name = "untrusted"

    service_delegation {
      name    = "PaloAltoNetworks.Cloudngfw/firewalls"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_palo_alto_local_rulestack" "rulestack" {
  name                = "lrs-${var.resource_prefix}-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_palo_alto_local_rulestack_rule" "rulestack_rule" {
  name         = "default-rule"
  rulestack_id = azurerm_palo_alto_local_rulestack.rulestack.id
  priority     = 1001
  action       = "Allow"

  applications = ["any"]

  destination {
    cidrs = ["any"]
  }

  source {
    cidrs = ["any"]
  }
}

resource "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack" "ngfwrs" {
  count              = var.enable_panorama ? 0 : 1
  name                = "ngfw-${var.resource_prefix}-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.rulestack.id

  network_profile {
    public_ip_address_ids = [azurerm_public_ip.public_ip.id]

    vnet_configuration {
      virtual_network_id  = azurerm_virtual_network.vnet.id
      trusted_subnet_id   = azurerm_subnet.trust_subnet.id
      untrusted_subnet_id = azurerm_subnet.untrust_subnet.id
    }
  }
}

resource "azurerm_palo_alto_next_generation_firewall_virtual_network_panorama" "ngfwpan" {
  count                  = var.enable_panorama ? 1 : 0
  name                   = "ngfw-${var.resource_prefix}-${var.resource_suffix}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  panorama_base64_config = var.panorama_base64_config

  network_profile {
    public_ip_address_ids = [azurerm_public_ip.public_ip.id]

    vnet_configuration {
      virtual_network_id  = azurerm_virtual_network.vnet.id
      trusted_subnet_id   = azurerm_subnet.trust_subnet.id
      untrusted_subnet_id = azurerm_subnet.untrust_subnet.id
    }
  }
}
