
#################################################################
##  This is the main file where we are calling the modules     ##
##  and passing the data to the modules from the main.tf       ##
## file. These are the examples to create VM,ADF,SQLMI, DB, RG ##
#################################################################

locals {
  suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"

  }
  suffix = lookup(local.suffix_map, var.app_env, "000") # Default to "000" if env is undefined
}

# locals {
#   custom_adf_name     = "adf-${var.workload}-${var.app_env}-${local.suffix}"
#   custom_ir_name      = "DefaultAutoResolve"
#   custom_shir_name    = "shir-${var.workload}-${var.app_env}-${local.suffix}"
#   custom_shir_vm_name = "azwa${var.workload}${local.suffix}"
# }



# # resource group should always be created first or should be available for the resources to be created
module "rg" {
  source = "./modules/rg"
  # passing the data from the main.tf to the module
  #app_rg   = var.app_rg
  app_rg          = var.app_rg
  location        = var.location
  rg_tags         = var.rg_tags
  rg_reader_group = var.app_ad_group
  app_env         = var.app_env
  #rg_contributor_group = var.app_rgadmin_group
}
data "azurerm_resource_group" "app" {
  #name       = var.app_rg
  #name       = module.rg.azurerm_resource_group.app.name
  name       = module.rg.name
  depends_on = [module.rg]
}

module "vm" {
  source = "./modules/vm"
  # passing the data from the main.tf to the module
  app_vnet    = data.azurerm_virtual_network.app.name
  app_snet    = data.azurerm_subnet.app.name
  app_vnet_rg = data.azurerm_virtual_network.app.resource_group_name
  app_rg      = data.azurerm_resource_group.app.name

  app_env = var.app_env
  app_vm  = var.app_vm
  #disksize = var.disksize
  public_network_enabled = var.public_network_enabled

  iac_rg = data.azurerm_resource_group.iac.name
  iac_st = data.azurerm_storage_account.iac.name
  iac_kv = data.azurerm_key_vault.iac.name

  # app_remote_group = ["G-CCOE-Admin-F", "G-Azure-Owner-F"]
  # app_admin_group  = ["G-CCOE-Admin-F", "G-Azure-Owner-F"]
  # app_ad_group     = "G-CCOE-Admin-F"
  depends_on = [module.rg, data.azurerm_resource_group.app]
}





# module "sqlmi_db" {
#   source = "./modules/sqlmi_db"
#   # passing the data from the main.tf to the module
#   app_sqlmi    = var.app_sqlmi
#   app_sqlmi_rg = var.app_sqlmi_rg
#   app_sqlmi_db = var.app_sqlmi_db
#   app_ad_group = var.app_ad_group
#   sql_ad_group = var.sql_ad_group

#   iac_rg = data.azurerm_resource_group.iac.name
#   iac_st = data.azurerm_storage_account.iac.name
#   iac_kv = data.azurerm_key_vault.iac.name

#   depends_on = [module.rg]
# }

# module "adf" {
#   source = "./modules/adf"
#   # passing the data from the main.tf to the module
#   app_rg      = data.azurerm_resource_group.app.name
#   app_env     = var.app_env
#   app_vnet    = var.app_vnet
#   app_vnet_rg = var.app_vnet_rg
#   app_snet    = var.app_snet
#   #app_vm      = var.app_vm
#   app_vm = local.custom_shir_vm_name

#   # adf parameters
#   location = data.azurerm_resource_group.app.location
#   #location    = var.location
#   environment = var.app_env
#   workload    = var.workload
#   #resource_group = data.resource_group.app.name
#   resource_group = data.azurerm_resource_group.app.name

#   #  custom_adf_name                         = local.custom_adf_name
#   #  custom_default_ir_nam                   = local.custom_default_ir_name
#   #  custom_diagnostics_name                 = local.custom_diagnostics_name
#   #  custom_shir_name                        = local.custom_shir_name
#   tags                                    = var.rg_tags
#   public_network_enabled                  = false
#   managed_virtual_network_enabled         = false

#   # the following is for the AutoResolve IR parameters
#   cleanup_enabled                         = true
#   compute_type                            = "General"
#   core_count                              = 8
#   time_to_live_min                        = 15
#   virtual_network_enabled                 = false

#   self_hosted_integration_runtime_enabled = true
#   #log_analytics_workspace
#   analytics_destination_type = "Dedicated"
#   #managed_private_endpoint   = null
#   #global_parameter           = null
#   # vsts_configuration = {
#   #   account_name    = "account_name"
#   #   branch_name     = "branch_name"
#   #   project_name    = "project_name"
#   #   repository_name = "repository_name"
#   #   root_folder     = "root_folder"
#   #   tenant_id       = "tenant_id"
#   # }
#   permissions = [
#     {
#       object_id = null
#       role      = null
#     }
#   ]
#   key_vault_name = data.azurerm_key_vault.iac.name

#   iac_rg = data.azurerm_resource_group.iac.name
#   iac_kv = data.azurerm_key_vault.iac.name
#   iac_st = data.azurerm_storage_account.iac.name

#   app_remote_group = var.app_remote_group
#   app_admin_group  = var.app_admin_group
#   app_ad_group     = var.app_ad_group


#   project = var.workload


#   #app_remote_group = ["G-CCOE-Admin-F", "G-Azure-Owner-F"]
#   #app_admin_group  = ["G-CCOE-Admin-F", "G-Azure-Owner-F"]
#   #app_ad_group     = "G-CCOE-Admin-F"

#   #rg_tags = var.rg_tags
#   depends_on = [module.rg]
# }

