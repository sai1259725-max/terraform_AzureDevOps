# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  address_space       = ["10.0.0.0/16"]
  location            = var.rglocation
  resource_group_name = var.rgname
}

# Subnets
resource "azurerm_subnet" "subnet_vm" {
  name                 = "subnet-web"
  resource_group_name  = var.rgname
  virtual_network_name = var.vnetname
  address_prefixes     = ["10.0.1.0/24"]

   depends_on = [azurerm_virtual_network.vnet]

}

resource "azurerm_subnet" "subnet_app" {
  name                 = "subnet-app"
  resource_group_name  = var.rgname
  virtual_network_name = var.vnetname
  address_prefixes     = ["10.0.2.0/24"]

   depends_on = [azurerm_virtual_network.vnet]

}
