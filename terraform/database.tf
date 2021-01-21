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

resource "azurerm_network_security_group" "metal-list-db" {
  name                = "metal-list-db"
  location            = azurerm_resource_group.metal-list.location
  resource_group_name = azurerm_resource_group.metal-list.name

  security_rule {
    name                       = "allow-ssh-in"
    priority                   = 100
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "database" {
  name                = "database-nic"
  location            = azurerm_resource_group.metal-list.location
  resource_group_name = azurerm_resource_group.metal-list.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.metal-list.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.database.id
  }

}

resource "azurerm_public_ip" "database" {
  name                = "database-ip"
  resource_group_name = azurerm_resource_group.metal-list.name
  location            = azurerm_resource_group.metal-list.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_storage_account" "metal-list-db" {
  name                     = "metalliststorageaccount"
  resource_group_name      = azurerm_resource_group.metal-list.name
  location                 = azurerm_resource_group.metal-list.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}

resource "azurerm_linux_virtual_machine" "metal-list-db" {
  name                            = "metal-list-db"
  resource_group_name             = azurerm_resource_group.metal-list.name
  location                        = azurerm_resource_group.metal-list.location
  size                            = "Standard_B1ls"
  admin_username                  = "metal-list-admin"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.database.id,
  ]

  admin_ssh_key {
    username   = "metal-list-admin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = "https://${azurerm_storage_account.metal-list-db.name}.blob.core.windows.net/"
  }
}

resource "azurerm_virtual_machine_extension" "metal-list-extension" {
  name                       = "hostname"
  virtual_machine_id         = azurerm_linux_virtual_machine.metal-list-db.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "DockerExtension"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "compose": {
        "postgres": {
            "image": "postgres",
            "restart": "always",
            "ports": [
                "5432:5432"
            ],
            "environment": [
                "POSTGRES_PASSWORD=${var.psql_pass}"
            ],
            "volumes": [
                "/var/lib/postgresql/data:/var/lib/postgresql/data"
            ]
        }
      }
    }
  SETTINGS

  protected_settings = <<SETTINGS
    {
      "environment": {
        "POSTGRES_PASSWORD": "${var.psql_pass}"
      }
    }
  SETTINGS
}