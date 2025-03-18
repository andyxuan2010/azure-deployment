data "azurerm_client_config" "current" {}
#data.azurerm_client_config.current.tenant_id
#data.azurerm_client_config.current.client_id
#data.azurerm_client_config.current.subscription_id

data "azurerm_subscriptions" "available" {}
#data.azurerm_subscriptions.available.subscriptions




#get existing vnet
data "azurerm_virtual_network" "app" {
  name                = var.app_vnet
  resource_group_name = var.app_vnet_rg
}

# get existing subnet inside a vnet
data "azurerm_subnet" "app" {
  name                 = var.app_snet
  virtual_network_name = var.app_vnet
  resource_group_name  = var.app_vnet_rg
}

#get existing resource group
data "azurerm_resource_group" "iac" {
  name = var.iac_rg
}
# get existing storage account, for iac purpose
data "azurerm_storage_account" "iac" {
  name                = var.iac_st
  resource_group_name = var.iac_rg
}
# get existing key vault and secret, for iac purpose
data "azurerm_key_vault" "iac" {
  name                = var.iac_kv
  resource_group_name = var.iac_rg
}

