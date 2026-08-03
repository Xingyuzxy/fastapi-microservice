locals {
    owners = var.business_divsion
    environment = var.environment
    resource_name_prefix = "${var.business_divsion}-${var.environment}"
    #name = "${local.owners}-${local.environment}"
    common_tags = {
        owners = local.owners
        environment = local.environment
    }
} 
# Create Resource Group 
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

resource "azurerm_storage_account" "mysa" {
    name                     = "mysa23"
    resource_group_name      = var.resource_group_name
    location                 = var.resource_group_location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

locals {
    webvm_custom_data = <<CUSTOM_DATA
    #!/bin/sh
    #!/bin/sh
    #sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd  
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
    sudo chmod -R 777 /var/www/html 
    sudo echo "Welcome to stacksimplify - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/index.html
    sudo mkdir /var/www/html/app1
    sudo echo "Welcome to stacksimplify - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html
    sudo echo "Welcome to stacksimplify - WebVM App1 - App Status Page" > /var/www/html/app1/status.html
    sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to Stack Simplify - WebVM APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
    sudo curl -H "Metadata:true" --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" -o /var/www/html/app1/metadata.html
    CUSTOM_DATA  
}


# Resource: Azure Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "web_linuxvm" {
    name = "${local.resource_name_prefix}-web-linuxvm"
    #computer_name = "web-linux-vm"  # Hostname of the VM (Optional)
    resource_group_name = var.resource_group_name
    location = var.resource_group_location
    size = "Standard_DS1_v2"
    admin_username = "azureuser"
    network_interface_ids = [ azurerm_network_interface.web_linuxvm_nic.id ]
    admin_ssh_key {
        username = "azureuser"
        public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "RedHat"
        offer = "RHEL"
        sku = "83-gen2"
        version = "latest"
    }
    #custom_data = filebase64("${path.module}/app-scripts/redhat-webvm-script.sh")    
    custom_data = base64encode(local.webvm_custom_data)  

}

# Resource-1: Create Public IP Address for Azure Load Balancer
resource "azurerm_public_ip" "web_lbpublicip" {
    name                = "${local.resource_name_prefix}-lbpublicip"
    resource_group_name = var.resource_group_name
    location            = var.resource_group_location
    allocation_method   = "Static"
    sku = "Standard"
    tags = local.common_tags
}

# Resource-2: Create Azure Standard Load Balancer
resource "azurerm_lb" "web_lb" {
    name                = "${local.resource_name_prefix}-web-lb"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
    sku = "Standard"
    frontend_ip_configuration {
        name                 = "web-lb-publicip-1"
        public_ip_address_id = azurerm_public_ip.web_lbpublicip.id
    }
    }
    
    # Resource-3: Create LB Backend Pool
    resource "azurerm_lb_backend_address_pool" "web_lb_backend_address_pool" {
    name                = "web-backend"
    loadbalancer_id     = azurerm_lb.web_lb.id
}

# Resource-4: Create LB Probe
resource "azurerm_lb_probe" "web_lb_probe" {
    name                = "tcp-probe"
    protocol            = "Tcp"
    port                = 80
    loadbalancer_id     = azurerm_lb.web_lb.id
    resource_group_name            = var.resource_group_name
}

# Resource-5: Create LB Rule
resource "azurerm_lb_rule" "web_lb_rule_app1" {
    name                           = "web-app1-rule"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = azurerm_lb.web_lb.frontend_ip_configuration[0].name
    backend_address_pool_id        = azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id 
    probe_id                       = azurerm_lb_probe.web_lb_probe.id
    loadbalancer_id                = azurerm_lb.web_lb.id
    resource_group_name            = var.resource_group_name
}


# Resource-6: Associate Network Interface and Standard Load Balancer
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association
resource "azurerm_network_interface_backend_address_pool_association" "web_nic_lb_associate" {
    network_interface_id    = azurerm_network_interface.web_linuxvm_nic.id
    ip_configuration_name   = azurerm_network_interface.web_linuxvm_nic.ip_configuration[0].name
    backend_address_pool_id = azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id
}


# Azure Bastion Service - Resources
## Resource-1: Azure Bastion Subnet
resource "azurerm_subnet" "bastion_service_subnet" {
    name                 = var.bastion_service_subnet_name
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.bastion_service_address_prefixes
}

# Resource-2: Azure Bastion Public IP
resource "azurerm_public_ip" "bastion_service_publicip" {
    name                = "${local.resource_name_prefix}-bastion-service-publicip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

# Resource-3: Azure Bastion Service Host
resource "azurerm_bastion_host" "bastion_host" {
    name                = "${local.resource_name_prefix}-bastion-service"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    
    ip_configuration {
        name                 = "configuration"
        subnet_id            = azurerm_subnet.bastion_service_subnet.id
        public_ip_address_id = azurerm_public_ip.bastion_service_publicip.id
    }
}


resource "azurerm_kubernetes_cluster" "aks" {
    name                = "aks-demo"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
    dns_prefix          = "aksdemo"

    oidc_issuer_enabled       = true
    workload_identity_enabled = true

    default_node_pool {
        name       = "system"
        node_count = 2
        vm_size    = "Standard_D2s_v3"
    }

    identity {
        type = "SystemAssigned"
    }
}