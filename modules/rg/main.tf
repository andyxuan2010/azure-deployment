resource "azurerm_resource_group" "app" {
  #count    = length(data.azurerm_resource_group.app) == 0 ? 1 : 0
  location = var.location
  name     = var.app_rg
  #   tags = merge(var.rg_tags, {
  #     workload = var.workload
  #     name     = var.app_rg
  #   })
  tags = var.rg_tags
}

# Get the Azure AD group by name
data "azuread_group" "reader" {
  count        = var.rg_reader_group != null && var.rg_reader_group != "" && var.app_env != "sbx" ? 1 : 0
  display_name = var.rg_reader_group # Replace with your AD group name
}
# data "azuread_group" "contributor" {
#   display_name = var.rg_contributor_group # Replace with your AD group name
# }

# # Assign the Reader role to the AD group for the resource group
resource "azurerm_role_assignment" "reader" {
  count                = var.rg_reader_group != null && var.rg_reader_group != "" && var.app_env != "sbx" ? 1 : 0
  scope                = azurerm_resource_group.app.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.reader[count.index].object_id
  depends_on           = [azurerm_resource_group.app, data.azuread_group.reader]
}
# # Assign the Reader role to the AD group for the resource group
# resource "azurerm_role_assignment" "contributor" {
#   scope                = azurerm_resource_group.app.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azuread_group.contributor.object_id
#   depends_on           = [azurerm_resource_group.app,data.azuread_group.contributor]
# }
