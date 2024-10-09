provider "azurerm" {
    features {}

    subscription_id = "30968ef3-435a-4ee2-8c06-7bb66267b87d"
}

resource "random_string" "name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_password" "password" {
  length           = 8
  lower            = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "mysqlfsVnetZone${random_string.name.result}.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.default.id

  depends_on = [azurerm_subnet.default]
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-acervantes"
  location = "Brazil South"
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet-acervantes"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-acervantes-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-acervantes-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "web-configuration"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-acervantes-web01"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username = "alaincervantesp"
  admin_password = "Ac890816*"
  disable_password_authentication = false

}

resource "azurerm_private_dns_zone" "default" {
  name                = "acervantes.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_mysql_flexible_server" "default" {
  name                = "mysql-acervantes-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "GP_Standard_D2ds_v4"
  backup_retention_days       = 7
  geo_redundant_backup_enabled = false
  administrator_login         = random_string.name.result
  administrator_password = random_password.password.result
  private_dns_zone_id          = azurerm_private_dns_zone.default.id
  version                    = "8.0.21"

  storage {
    iops    = 360
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
  
}

resource "azurerm_mysql_flexible_database" "main" {
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"  
  name                = "db-acervantes-app"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.default.name
}


resource "azurerm_public_ip" "public_ip" {
  name                = "acervantes-ip-publica"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"   
}

resource "azurerm_lb" "loadbalancer" {
  name                = "lb-acervantes-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}


resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id     = azurerm_lb.loadbalancer.id
  name                = "backend-pool"
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "tcp-probe"
  loadbalancer_id     = azurerm_lb.loadbalancer.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  name                            = "http-lb-rule" 
  loadbalancer_id                 = azurerm_lb.loadbalancer.id
  frontend_ip_configuration_name  = "PublicIPAddress"
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                        = azurerm_lb_probe.lb_probe.id
}