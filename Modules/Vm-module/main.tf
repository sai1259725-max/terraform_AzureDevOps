# Public IP
resource "azurerm_public_ip" "pip" {
  name = "${var.vmname}-pip"
  location            = var.rglocation
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name = "${var.vmname}-nic"
  location            = var.rglocation
  resource_group_name = var.rgname

  ip_configuration {
    name = "${var.vmname}-ipcfg"
    subnet_id                     = var.subnetid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Windows VM
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vmname
   location            = var.rglocation
  resource_group_name = var.rgname
  size                  = var.vmsize
  admin_username        = var.vmusername
  admin_password        = var.vmpassword  # ⚠️ Use secure methods in production
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
  environment = "dev"
  owner       = "sai"
}
}

resource "azurerm_network_security_group" "nsg" {
  name = "${var.vmname}-nsg"
  location            = var.rglocation
  resource_group_name = var.rgname

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
