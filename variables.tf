variable "common_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "Need to fill"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "prod"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "Need to fill"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "00000"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "0"
  }
}

#resource group specific tags
variable "rg_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "Need to fill"
    "Application Owner"                 = "Need to fill"
    "AppSupport Team"                   = "Need to fill"
    "Approval Group"                    = "Need to fill"
    "Business Owner"                    = "Need to fill"
    "Environment"                       = "Need to fill"
    "Infra Availability Classification" = "Need to fill"
    "InfraSupport Team"                 = "Need to fill"
    "Maintenance Window"                = "Need to fill"
    "Project Status"                    = "Need to fill"
    "Project Name"                      = "Need to fill"
    "Project Number"                    = "Need to fill"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "50"
    "workload"                          = "project"
    "IaC"                               = "Terraform"
    "Requested By"                      = "Need to fill"
    "Provisioned By"                    = "Need to fill"
    "Technical contact"                 = "Need to fill"
    "Business contact"                  = "Need to fill"
  }
}

variable "location" {
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "app_env" {
  type        = string
  description = "Environment, the environment name such as 'stg', 'prd', 'dev'"
  validation {
    condition     = var.app_env == null ? true : contains(["prod", "nprod", "dev", "test", "sbx", "lab"], var.app_env)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}


# We have [F0 F1 S0 S S1 S2 S3 S4 S5 S6 P0 P1 P2 E0 DC0]
# for demo purpose we pick S0 plan, we need to apply for the service to be enabled.
variable "sku" {
  type        = string
  description = "The sku name of the Azure Cognitive Services server to create. Choose from: [F0 F1 S0 S S1 S2 S3 S4 S5 S6 P0 P1 P2 E0 DC0]"
  default     = "S0"
}

variable "iac_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}
variable "iac_kv" {
  type        = string
  description = "The name of the key vault in which the secrets will be stored."
}
variable "iac_st" {
  type        = string
  description = "The name of the storage account in which the Terraform state will be stored."
}

variable "workload" {
  type        = string
  description = "The name of the workload to be deployed."
  default     = "project"
}

variable "app_vnet" {
  type        = string
  description = "The name of the virtual network in which the resources will be created."
}

variable "app_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}
variable "app_vm" {
  type        = string
  description = "The name of the virtual machine to be created."
}


variable "app_snet" {
  type        = string
  description = "The name of the subnet in which the resources will be created."
}
variable "app_vnet_rg" {
  type        = string
  description = "The name of the resource group in which the virtual network is located."
}
variable "app_remote_group" {
  type        = list(string)
  description = "The list of groups that will have remote access to the resources."
  default     = ["G-CCOE-Admin-F"]
}
variable "app_admin_group" {
  type        = list(string)
  description = "The list of groups that will have administrative access to the resources."
  default     = ["G-CCOE-Admin-F"]
}
variable "app_ad_group" {
  type        = string
  description = "The name of the group that will have reader access to the resources."
  default     = "G-CCOE-Admin-F"
}
variable "app_rgadmin_group" {
  type        = string
  description = "The name of the group that will have administrative access to the resources."
  default     = "G-CCOE-Admin-F"
}
variable "disksize" {
  type        = number
  description = "The size of the disk to be attached to the virtual machine."
  default     = 0
}
variable "app_sqlmi" {
  type        = string
  description = "The name of the Azure SQL Managed Instance to be created."
}
variable "app_sqlmi_db" {
  type        = string
  description = "The name of the Azure SQL Managed Database to be created."
}
variable "app_sqlmi_rg" {
  type        = string
  description = "The name of the resource group in which the Azure SQL Managed Instance will be created."
}

variable "sql_ad_group" {
  type        = string
  description = "The name of the group that will have reader access to the SQL Managed Instance."
  default     = "G-Azure-Owner-F"
}
variable "public_network_enabled" {
  type    = bool
  default = false
}