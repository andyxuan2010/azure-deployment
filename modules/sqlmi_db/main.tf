#get existing resource group
data "azurerm_resource_group" "iac" {
  name = var.iac_rg
}

data "azurerm_storage_account" "iac" {
  name                = var.iac_st
  resource_group_name = var.iac_rg
}
# get existing key vault and secret, for iac purpose
data "azurerm_key_vault" "iac" {
  name                = var.iac_kv
  resource_group_name = var.iac_rg
}

data "azurerm_key_vault_secret" "sqladminuser-password" {
  name         = "sqladminuser-password"
  key_vault_id = data.azurerm_key_vault.iac.id
}

# Reference the existing Azure SQL Managed Instance
data "azurerm_mssql_managed_instance" "this" {
  name                = var.app_sqlmi
  resource_group_name = var.app_sqlmi_rg
}

# data "azurerm_windows_virtual_machine" "win-cicd-id" {
#   name                = "AZUWASHA001"
#   resource_group_name = "rg-ba-cc-devops-ci-cd-prod"  # Resource group where the identity is created
# }

# data "azurerm_linux_virtual_machine" "linux-cicd-id" {
#   name                = "AZULASHA001"
#   resource_group_name = "rg-ba-cc-devops-ci-cd-prod"
# }

# data "azurerm_virtual_machine" "cicdvms" {
#   for_each            = toset(var.cicdvms)
#   name                = each.value
#   resource_group_name = "rg-ba-cc-devops-ci-cd-prod"
# }
# resource "azurerm_role_assignment" "sqlmi_contributors" {
#   for_each            = data.azurerm_virtual_machine.cicdvms
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "Contributor"
#   principal_id         = each.value.identity[0].principal_id
# }

# resource "azurerm_role_assignment" "sqlmi_contributor_win" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.win-cicd-id.principal_id
# }
# resource "azurerm_role_assignment" "sqlmi_contributor_linux" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.linux-cicd-id.principal_id
# }

resource "azurerm_mssql_managed_database" "this" {
  name                = var.app_sqlmi_db
  managed_instance_id = data.azurerm_mssql_managed_instance.this.id
  tags                = data.azurerm_mssql_managed_instance.this.tags
  depends_on          = [data.azurerm_mssql_managed_instance.this]
}

# Get the Azure AD group by name
data "azuread_group" "app" {
  display_name = var.app_ad_group # Replace with your AD group name
}

# resource "azurerm_role_assignment" "vm2mi" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "reader"
#   principal_id         = azurerm_windows_virtual_machine.this.identity.0.principal_id
#   depends_on           = [data.azurerm_storage_account.iac, azurerm_windows_virtual_machine.this]
# }

resource "azurerm_role_assignment" "app2mi" {
  count       = var.app_env == "sbx" ? 0 : 1
  scope                = data.azurerm_mssql_managed_instance.this.id
  role_definition_name = "reader"
  principal_id         = data.azuread_group.app[count.index].object_id
}
# resource "azurerm_role_assignment" "vm2kv" {
#   scope                = data.azurerm_key_vault.iac.id
#   role_definition_name = "Key Vault Reader"
#   principal_id         = azurerm_windows_virtual_machine.this.identity.0.principal_id
#   depends_on           = [data.azurerm_key_vault.iac, azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_role_assignment" "vm2kvsecrets" {
#   scope                = data.azurerm_key_vault.iac.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_windows_virtual_machine.this.identity.0.principal_id
#   depends_on           = [data.azurerm_key_vault.iac, azurerm_windows_virtual_machine.this]
# }

# try to create a user in the database
# resource "null_resource" "create_sql_users" {
#   depends_on = [azurerm_mssql_managed_database.this]

#   provisioner "local-exec" {
#     command = <<EOT
#       sqlcmd -S ${data.azurerm_mssql_managed_instance.this.fqdn} -U ${data.azurerm_mssql_managed_instance.this.administrator_login} -P "${data.azurerm_key_vault_secret.sqladminuser-password.value}" -Q "CREATE LOGIN [${var.sql_ad_group}] FROM EXTERNAL PROVIDER;"
#       sqlcmd -S ${data.azurerm_mssql_managed_instance.this.fqdn} -d ${azurerm_mssql_managed_database.this.name} -U ${data.azurerm_mssql_managed_instance.this.administrator_login} -P "${data.azurerm_key_vault_secret.sqladminuser-password.value}" -Q "CREATE USER [${var.sql_ad_group}] FROM EXTERNAL PROVIDER;ALTER ROLE db_owner ADD MEMBER [${var.sql_ad_group}];"
#     EOT
#   }
# }

