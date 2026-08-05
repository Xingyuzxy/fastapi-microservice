resource "azurerm_kubernetes_cluster" "aks" {
    name                = "aks-demo"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
    dns_prefix          = "aks-demo"

    default_node_pool {
        name       = "default"
        node_count = 2
        vm_size    = "Standard_D2s_v3"
    }

    node_provisioning_profile {
        mode = "Manual"
    }

    identity {
        type = "SystemAssigned"
    }

    tags = {
        Environment = "dev"
    }
    }