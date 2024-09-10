locals {
  region = "eastus"
  tags = {
    "project" = "delta"
    "billing_code" = "abc101"
    "department" = "engineering"
  }

    vmsize = {
        "small" = "Basic_A0"
        "medium" = "Basic_A1"
        "large" = "Basic_A2"
    }
}

resource "azurerm_resource_group" "rg" {
  name = var.rgname
  location = local.region
}

resource "azurerm_virtual_network" "vnet" {
  address_space = var.vnetsuffix
  name = var.vnetname
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}

resource "azurerm_subnet" "web" {
  address_prefixes = var.subnetsuffix
  name = var.subnetname
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}


# Public ip for the public VM
resource "azurerm_public_ip" "vmpubip" {
  name                = "vmpubip"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku = "Basic"
  tags = local.tags
}

resource "azurerm_network_interface" "web" {
  name                = "web-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.vmname}-NIC"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vmpubip.id
  }  
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = var.vmname
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = local.vmsize[var.size]  # local.vmsize["small"]  # Basic_A0
  admin_username      = var.adminuser
  network_interface_ids = [
    azurerm_network_interface.web.id,
  ]

  admin_ssh_key {
    username   = var.adminuser
    public_key = var.adminkey
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

