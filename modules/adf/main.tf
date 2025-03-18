locals {
  suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"

  }
  suffix = lookup(local.suffix_map, var.environment, "000") # Default to "000" if env is undefined
}

locals {
  adf_name  = var.custom_adf_name == null ? "adf-${var.project}-${var.environment}-${local.suffix}" : var.custom_adf_name
  ir_name   = var.custom_default_ir_name == null ? "DefaultAutoResolve" : var.custom_default_ir_name
  shir_name = var.custom_shir_name == null ? "shir-${var.project}-${var.environment}-${local.suffix}" : var.custom_shir_name
}

resource "azurerm_data_factory" "this" {
  name                            = local.adf_name
  location                        = var.location
  resource_group_name             = var.resource_group
  public_network_enabled          = var.public_network_enabled
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  tags                            = var.rg_tags

  identity {
    type = "SystemAssigned"
  }

  dynamic "global_parameter" {
    for_each = { for i in var.global_parameter : i.name => i if i.name != null }

    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  dynamic "vsts_configuration" {
    for_each = length(var.vsts_configuration) == 0 ? [] : [var.vsts_configuration]

    content {
      account_name    = var.vsts_configuration.account_name
      branch_name     = var.vsts_configuration.branch_name
      project_name    = var.vsts_configuration.project_name
      repository_name = var.vsts_configuration.repository_name
      root_folder     = var.vsts_configuration.root_folder
      tenant_id       = var.vsts_configuration.tenant_id
    }
  }

  lifecycle {
    ignore_changes = [
      global_parameter,
    ]
  }
}

resource "azurerm_role_assignment" "data_factory" {
  for_each = {
    for permission in var.permissions : "${permission.object_id}-${permission.role}" => permission
    if permission.role != null
  }
  scope                = azurerm_data_factory.this.id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
}

resource "azurerm_data_factory_integration_runtime_azure" "auto_resolve" {
  data_factory_id         = azurerm_data_factory.this.id
  location                = "AutoResolve"
  name                    = local.ir_name
  time_to_live_min        = var.time_to_live_min
  virtual_network_enabled = var.virtual_network_enabled
  cleanup_enabled         = var.cleanup_enabled
  compute_type            = var.compute_type
  core_count              = var.core_count
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "this" {
  count = var.self_hosted_integration_runtime_enabled ? 1 : 0

  name            = local.shir_name
  data_factory_id = azurerm_data_factory.this.id
}


# Get the Azure AD group by name
data "azuread_group" "adf" {
  display_name = var.app_ad_group # Replace with your AD group name
}

resource "azurerm_role_assignment" "reader" {
  count                = var.app_ad_group != null && var.app_ad_group != "" && var.app_env != "sbx" ? 1 : 0
  scope                = azurerm_data_factory.this.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.adf.object_id
  depends_on           = [azurerm_data_factory.this, data.azuread_group.adf]
}

# this is the example to create the SHIR- Self Hosted Integration Runtime
module "shir" {
  #count = var.self_hosted_integration_runtime_enabled ? 1 : 0
  source = "../vm"
  # passing the data from the main.tf to the module
  app_vnet    = data.azurerm_virtual_network.app.name
  app_snet    = data.azurerm_subnet.app.name
  app_vnet_rg = data.azurerm_virtual_network.app.resource_group_name
  app_rg      = var.resource_group

  app_env = var.app_env
  #app_vm  = local.shir_vm_name
  app_vm  = var.app_vm

  iac_rg = data.azurerm_resource_group.iac.name
  iac_st = data.azurerm_storage_account.iac.name
  iac_kv = data.azurerm_key_vault.iac.name

  app_remote_group = ["G-CCOE-Admin-F", "G-CCOE-Owner-F"]
  app_admin_group  = ["G-CCOE-Admin-F", "G-CCOE-Owner-F"]
  app_ad_group     = "G-CCOE-Admin-F"
  depends_on       = [azurerm_data_factory.this]
}