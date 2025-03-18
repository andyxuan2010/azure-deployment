# Assuming the resource group has not been created.
# data "azurerm_resource_group" "app" {
#   name = var.app_rg
# }

# resource "azurerm_resource_group" "app" {
#   #count    = length(data.azurerm_resource_group.app) == 0 ? 1 : 0
#   location = var.location
#   name     = var.app_rg
#   tags = merge(var.rg_tags, {
#     workload = var.workload
#     name     = var.app_rg
#   })
# }

# Assign the Reader role to the AD group for the resource group
# resource "azurerm_role_assignment" "reader" {
#   scope                = data.azurerm_resource_group.app.id
#   role_definition_name = "Reader"
#   principal_id         = data.azuread_group.app.object_id
# }

# locals {
#   app_rg = length(try(data.azurerm_resource_group.app.name, "")) == 0 ? azurerm_resource_group.app[0].name : data.azurerm_resource_group.app.name
# }

# resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
#   count                      = var.AADLoginForWindows == true ? 1 : 0
#   name                       = "AADLoginForWindows"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.ActiveDirectory"
#   type                       = "AADLoginForWindows"
#   type_handler_version       = "2.2"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }


# resource "azurerm_virtual_machine_extension" "VMAccessAgent" {
#   name                       = "VMAccessAgent"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "VMAccessAgent"
#   type_handler_version       = "2.4"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
# }
resource "azurerm_virtual_machine_extension" "NetworkWatcherAgentWindows" {
  name                       = "NetworkWatcherAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  depends_on                 = [azurerm_windows_virtual_machine.this]
  tags                       = var.rg_tags
  lifecycle {
    ignore_changes = [tags]
  }
}
# resource "azurerm_virtual_machine_extension" "BGInfo" {
#   name                       = "BGInfo"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "BGInfo"
#   type_handler_version       = "2.2.3"
#   tags                       = var.common_tags
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_virtual_machine_extension" "WindowsOpenSSH" {
#   name                       = "WindowsOpenSSH"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.OpenSSH"
#   type                       = "WindowsOpenSSH"
#   type_handler_version       = "3.0"
#   # auto_upgrade_minor_version = true
#   # tags                       = var.rg_tags
#   # depends_on                 = [azurerm_windows_virtual_machine.this]
#   # lifecycle {
#   #   ignore_changes = [tags]
#   # }
# }
# resource "azurerm_virtual_machine_extension" "KeyVaultForWindows" {
#   name                 = "KeyVaultForWindows"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Azure.KeyVault"
#   type                 = "KeyVaultForWindows"
#   type_handler_version = "1.0"
#   auto_upgrade_minor_version = true
#   depends_on           = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_virtual_machine_extension" "AntimalwareConfiguration" {
#   name                 = "AntimalwareConfiguration"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Azure.Security.AntimalwareSignature"
#   type                 = "AntimalwareConfiguration"
#   type_handler_version = "2.159"
#   auto_upgrade_minor_version = true
#   depends_on           = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_virtual_machine_extension" "IaaSAntimalware" {
#   name                       = "IaaSAntimalware"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.Security"
#   type                       = "IaaSAntimalware"
#   type_handler_version       = "1.7"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#         {
#           "AntimalwareEnabled": true,
#           "RealtimeProtectionEnabled": "true",
#           "ScheduledScanSettings": {
#             "isEnabled": "true",
#             "day": "7",
#             "time": "120",
#             "scanType": "quick"
#           },
#           "Exclusions": {
#             "Extensions": "",
#             "Paths": "",
#             "Processes": ""
#           }
#         }
#   SETTINGS
#   tags                       = var.rg_tags
#   depends_on                 = [azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_virtual_machine_extension" "DatadogWindowsAgent" {
#   name                       = "DDAgentExtension"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Datadog.Agent"
#   type                       = "DatadogWindowsAgent"
#   type_handler_version       = "7.0"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#         {
#           "api_key": "${var.datadog_api_key}"
#         }
#   SETTINGS
#   protected_settings         = <<PROTECTED_SETTINGS
#   {
#     "DATADOG_API_KEY": "${var.datadog_api_key}"
#   }
#   PROTECTED_SETTINGS
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }
# resource "azurerm_virtual_machine_extension" "QualysAgent" {
#   name                 = "QualysWindowsAgent"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Qualys"
#   type                 = "QualysAgent"
#   type_handler_version = "3.1"
#   auto_upgrade_minor_version = true
#   tags                       = var.rg_tags
#   depends_on           = [azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_virtual_machine_extension" "AzureMonitorWindowsAgent" {
#   name                       = "AzureMonitorWindowsAgent"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.Monitor"
#   type                       = "AzureMonitorWindowsAgent"
#   type_handler_version       = "1.23"
#   auto_upgrade_minor_version = true
#   tags                       = var.rg_tags
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_virtual_machine_extension" "VMAccessAgent" {
#   name                 = "VMAccessAgent"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Compute"
#   type                 = "VMAccessAgent"
#   type_handler_version = "2.*"
#   auto_upgrade_minor_version = true
#   tags = var.common_tags
#   depends_on           = [azurerm_windows_virtual_machine.this]
# }

# Create network interface if we need to have a static ip
resource "azurerm_network_interface" "this" {
  name                = "nic-${var.workload}-cc-${var.app_env}-001"
  location            = var.location
  resource_group_name = var.app_rg

  # ip_configuration {
  #   name                          = "nicconfig-${var.workload}-cc-${var.app_env}"
  #   subnet_id                     = data.azurerm_subnet.app.id
  #   private_ip_address_allocation = "Dynamic"
  #   # private_ip_address_allocation = "Static"
  #   # private_ip_address            = var.staticIP
  # }

  #to support public ip in the sandbox environment
  # Conditionally add public IP if enabled
  dynamic "ip_configuration" {
    for_each = var.public_network_enabled ? [1] : []
    content {
      name                          = "public-ip-config"
      subnet_id                     = data.azurerm_subnet.app.id
      public_ip_address_id          = azurerm_public_ip.this[0].id
      private_ip_address_allocation = "Dynamic"
    }
  }  


  tags       = var.rg_tags
  depends_on = [data.azurerm_resource_group.app]
}

resource "azurerm_virtual_machine_extension" "domain_join_ext" {
  # We don't join the domain in the sandbox environment since AAD is not integrated in sbx env.
  count                      = var.app_env != "sbx" ? 1 : 0 # Provision only if app_env is NOT "sbx"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  name                       = "JsonADDomainExtension"
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "Name": "${var.domain}",
      "OUPath": "",
      "User": "${var.domain_join_user}",
      "Restart": "false",
      "Options": "3"
    }
  SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "Password": "${data.azurerm_key_vault_secret.domain-join-password[count.index].value}"
    }
  PROTECTED_SETTINGS
  #      "Password": "${var.domain_join_pass}"
  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
  timeouts {
    create = "10m"
    delete = "10m"
  }
  tags = var.rg_tags
  #depends_on = [azurerm_virtual_machine_extension.CustomScriptInit, azurerm_windows_virtual_machine.this]
  depends_on = [azurerm_windows_virtual_machine.this]
}


resource "azurerm_windows_virtual_machine" "this" {
  name                = var.app_vm
  computer_name       = var.app_vm
  resource_group_name = var.app_rg
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = data.azurerm_key_vault_secret.azure-user.value
  admin_password      = data.azurerm_key_vault_secret.azure-password.value
  # admin_username = var.azure-user
  # admin_password = var.azure-password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows-sku
    version   = "latest"
  }
  identity {
    type = "SystemAssigned"

  }

  patch_assessment_mode = "AutomaticByPlatform"
  # custom_data is a backup plan if the storage account is not accessible
  custom_data        = base64encode(local.init_script)
  provision_vm_agent = true
  vm_agent_platform_updates_enabled = true
  tags               = var.rg_tags
}

resource "azurerm_managed_disk" "this" {
  count                 = var.disksize > 0 ? 1 : 0 # Provision only if disksize > 0
  name                  = "${var.app_vm}-disk2"
  location              = var.location
  resource_group_name   = var.app_rg
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  network_access_policy = "AllowAll"
  disk_size_gb          = var.disksize
  tags                  = var.rg_tags
  depends_on            = [data.azurerm_resource_group.app, azurerm_windows_virtual_machine.this]
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count              = var.disksize > 0 ? 1 : 0 # Attach only if the disk exists
  managed_disk_id    = azurerm_managed_disk.this[0].id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on         = [azurerm_managed_disk.this, azurerm_windows_virtual_machine.this]
}

# these 2 scripts should be identical, but the init.ps1 is the one that will be run by the CustomScriptExtension
# if storage account is not accessible then we may need to use the template_file to create the script.
#      "${data.azurerm_storage_container.scripts.id}/scheduled.ps1"

locals {
  fileUris = <<EOT
    [
      "${data.azurerm_storage_container.scripts.id}/init.ps1"
    ]
    EOT
  init_script = templatefile("${path.module}/scripts/init.ps1", {
    AppEnv = "sbx" # Optional: Pass variables to the script
  })
}

locals {
  app_remote_group_list = join(",", var.app_remote_group)
  app_admin_group_list  = join(",", var.app_admin_group)
}

resource "azurerm_virtual_machine_extension" "CustomScriptInit" {
  name                 = "CustomScriptInit"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  #auto_upgrade_minor_version = true

  # if the storage account is not accessible, then we may need to use the template_file to create the script.
  #"commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -command \"cp c:/azuredata/customdata.bin c:/azuredata/init.ps1; c:/azuredata/init.ps1\""
  settings = <<SETTINGS
  {
      "fileUris": ${local.fileUris},
      "commandToExecute": "powershell -ExecutionPolicy Bypass -File init.ps1 -Env sbx -LogFile c:\\InitLog.txt -AppRemoteGroup ${local.app_remote_group_list} -AppAdminGroup ${local.app_admin_group_list}"
  }
  SETTINGS

  #"powershell -ExecutionPolicy Bypass -Command \"& { .\\init.ps1; .\\createdbuser.ps1 }\""
  tags = var.rg_tags
  #depends_on = [azurerm_role_assignment.vm2st, azurerm_windows_virtual_machine.this]
  depends_on = [azurerm_windows_virtual_machine.this, azurerm_virtual_machine_extension.domain_join_ext]
}


resource "azurerm_role_assignment" "vm2st" {
  scope = data.azurerm_storage_account.iac.id
  #scope                = data.azurerm_storage_container.scripts.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_windows_virtual_machine.this.identity.0.principal_id
  depends_on           = [data.azurerm_storage_account.iac, azurerm_windows_virtual_machine.this]
}


resource "azurerm_role_assignment" "vm2kv" {
  scope                = data.azurerm_key_vault.iac.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_windows_virtual_machine.this.identity.0.principal_id
  depends_on           = [data.azurerm_key_vault.iac, azurerm_windows_virtual_machine.this]
}
resource "azurerm_role_assignment" "vm2kvsecrets" {
  scope                = data.azurerm_key_vault.iac.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_windows_virtual_machine.this.identity.0.principal_id
  depends_on           = [data.azurerm_key_vault.iac, azurerm_windows_virtual_machine.this]
}



resource "azurerm_public_ip" "this" {
  count              = var.public_network_enabled == true ? 1 : 0
  name               = "pip-${var.workload}-cc-${var.app_env}-001"
  location           = var.location
  resource_group_name = var.app_rg
  allocation_method  = "Dynamic"
  sku                = "Basic"
  tags               = var.rg_tags
  depends_on         = [data.azurerm_resource_group.app]
}

resource "azurerm_network_security_group" "this" {
  count              = var.public_network_enabled == true ? 1 : 0
  name                = "nsg-${var.workload}-cc-${var.app_env}-001"
  location            = var.location
  resource_group_name = var.app_rg

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags                = var.rg_tags
  depends_on          = [data.azurerm_resource_group.app]
}

resource "azurerm_network_interface_security_group_association" "this" {
  count                       = var.public_network_enabled == true ? 1 : 0
  network_interface_id        = azurerm_network_interface.this.id
  network_security_group_id   = azurerm_network_security_group.this[count.index].id
  depends_on                  = [azurerm_network_security_group.this, azurerm_network_interface.this]
}