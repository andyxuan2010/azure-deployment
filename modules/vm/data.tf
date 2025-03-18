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

data "azurerm_resource_group" "app" {
  name = var.app_rg
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

data "azurerm_key_vault_secret" "azure-user" {
  name         = "azure-user"
  key_vault_id = data.azurerm_key_vault.iac.id
}
data "azurerm_key_vault_secret" "azure-password" {
  name         = "azure-password"
  key_vault_id = data.azurerm_key_vault.iac.id
}
#skip domain join password for sandbox environment
data "azurerm_key_vault_secret" "domain-join-password" {
  count       = var.app_env == "sbx" ? 0 : 1
  name         = "domain-join-password"
  key_vault_id = data.azurerm_key_vault.iac.id
}
# get an existing managed identity
# data "azurerm_user_assigned_identity" "identity" {
#   name                = "my-identity"
#   resource_group_name = "my-resource-group"
# }

# get an existing app service
# data "azurerm_app_service" "app" {
#   name                = "my-app-service"
#   resource_group_name = "my-resource-group"
# }

# this is the windows init script before init.ps1 run.
# first run init.cmd, then init.ps1 and then scheduled.ps1
# data "template_file" "cloud-init" {
#   template = file("${path.module}/scripts/cloud-init.ps1")
# }

data "azurerm_storage_container" "scripts" {
  name                 = "scripts"
  storage_account_name = var.iac_st
}


# Get the Azure AD group by name
data "azuread_group" "app" {
  count       = var.app_env == "sbx" ? 0 : 1
  display_name = var.app_ad_group # Replace with your AD group name
}