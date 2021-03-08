resource "azurerm_virtual_network" "metal-list" {
  name                = "metal-list-network"
  address_space       = ["10.1.0.0/24"]
  location            = azurerm_resource_group.metal-list.location
  resource_group_name = azurerm_resource_group.metal-list.name
}

resource "azurerm_subnet" "metal-list" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.metal-list.name
  virtual_network_name = azurerm_virtual_network.metal-list.name
  address_prefixes     = ["10.1.0.0/24"]
}
