

# Helper: sanitized name (lowercase, spaces -> dash)
locals {
  safe_name = lower(replace(var.vmname, " ", "-"))
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "${local.safe_name}-pip"
  location            = var.rglocation
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${local.safe_name}-nic"
  location            = var.rglocation
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "${local.safe_name}-ipcfg"
    subnet_id                     = var.subnetid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Network Security Group (basic: allow SSH)
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.safe_name}-nsg"
  location            = var.rglocation
  resource_group_name = var.rgname

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
    name                       = "Allow-Port80"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Port8080"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vmname
  resource_group_name = var.rgname
  location            = var.rglocation
  size                = var.vmsize
  admin_username      = var.vmusername
  admin_password      = var.vmpassword
  disable_password_authentication = false    # 🔥 This enables password login

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  #tags = merge({ created_by = "terraform" }, var.tags)
}

