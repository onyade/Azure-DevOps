# Define the provider for Azure
provider "azurerm" {
  features {}
}

# Define the resource group that will contain the Azure resources
resource "azurerm_resource_group" "myresourcegroup" {
  name     = "myresourcegroup"
  location = "East US"
}

# Define the virtual network and subnet that the VM will use
resource "azurerm_virtual_network" "myvirtualnetwork" {
  name                = "myvirtualnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  subnet {
    name           = "mysubnet"
    address_prefix = "10.0.0.0/24"
  }
}

# Define the public IP address that the VM will use
resource "azurerm_public_ip" "mypublicip" {
  name                = "mypublicip"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  allocation_method   = "Dynamic"
}

# Define the network interface for the VM
resource "azurerm_network_interface" "mynetworkinterface" {
  name                = "mynetworkinterface"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  ip_configuration {
    name                          = "myipconfig"
    subnet_id                     = azurerm_virtual_network.myvirtualnetwork.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublicip.id
  }
}

# Define the virtual machine
resource "azurerm_virtual_machine" "myvirtualmachine" {
  name                  = "myvirtualmachine"
  location              = azurerm_resource_group.myresourcegroup.location
  resource_group_name   = azurerm_resource_group.myresourcegroup.name
  network_interface_ids = [azurerm_network_interface.mynetworkinterface.id]
  vm_size               = "Standard_D2_v2"

  storage_os_disk {
    name              = "myosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "myadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo service nginx start"
    ]
  }
}

# Define the output for the public IP address
output "public_ip_address" {
  value = azurerm_public_ip.mypublicip.ip_address
}
