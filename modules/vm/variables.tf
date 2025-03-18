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
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa'"
  validation {
    condition     = var.app_env == null ? true : contains(["prod", "dev", "qa", "sbx", "poc"], var.app_env)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}

variable "workload" {
  type        = string
  default     = "ccoetest"
  description = "Default prefix of the resource group name that will be created."
}

variable "azure-user" {
  type    = string
  default = "azureadmin"
}
variable "azure-password" {
  type    = string
  default = "DefaultPassword!"
}


variable "AADLoginForWindows" {
  description = "Should the VM be include the dependancy agent"
  default     = true
  type        = bool
}

variable "datadog_api_key" {
  type    = string
  default = "api_key"
}

variable "windows-sku" {
  type    = string
  default = "2022-Datacenter"
}

variable "disksize" {
  type    = number
  default = 0
}





# to define tfvars
variable "iac_rg" {
  type = string
}
variable "iac_kv" {
  type = string
}
variable "iac_st" {
  type = string
}
variable "app_rg" {
  type = string
}
variable "app_snet" {
  type = string
}
variable "app_vnet_rg" {
  type = string
}
variable "app_vnet" {
  type = string
}
variable "app_vm" {
  type = string
}
# variable "app_env" {
#   type = string
# }

variable "domain" {
  type    = string
  default = "example.com"
}
variable "domain_join_user" {
  type    = string
  default = "azureadmin"
}
# variable "domain_join_pass" {
#   type      = string
#   sensitive = true
#   default   = ">1R%h.H4VdcB"
# }
variable "domain_join_ou" {
  type    = string
  default = "azure"
}
variable "app_remote_group" {
  type    = list(string)
  default = ["G-CCOE-Admin-F", "G-Azure-Owner-F"]
}
variable "app_admin_group" {
  type    = list(string)
  default = ["G-CCOE-Admin-F", "G-Azure-Owner-F"]
}
variable "app_ad_group" {
  type    = string
  default = "G-CCOE-Admin-F"
}

variable public_network_enabled {
  type    = bool
  default = false
}