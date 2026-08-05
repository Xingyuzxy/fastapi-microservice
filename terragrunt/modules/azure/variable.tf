variable "resource_group_location" {
    type        = string
    default     = "eastus"
    description = "Location of the resource group."
}


variable "resource_group_name" {
    type        = string
    default     = "kml_rg_main-a1d8c1809b604426"
    description = "Resource group name in your Azure subscription."
}

variable "business_divsion" {
    description = "Business Division in the large organization this Infrastructure belongs"
    type = string
    default = "sap"
}
# Environment Variable
variable "environment" {
    description = "Environment Variable used as a prefix"
    type = string
    default = "dev"
}