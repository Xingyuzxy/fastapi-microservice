resource "azurerm_virtual_network" "myvnet" {
    name                = "myvnet-1"
    address_space       = ["10.0.0.0/16"]
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
}

# Resource-3: Create Subnet
resource "azurerm_subnet" "mysubnet" {
    name                 = "mysubnet-1"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.myvnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

# Resource-4: Create Public IP Address
resource "azurerm_public_ip" "mypublicip" {
    name                = "mypublicip-1"
    resource_group_name = var.resource_group_name
    location            = var.resource_group_location
    allocation_method   = "Static"
    tags = {
        environment = "Dev"
    }
}

# Resource-5: Create Network Interface
resource "azurerm_network_interface" "myvm1nic" {
    name                = "vm1-nic"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.mypublicip.id 
    }
}
