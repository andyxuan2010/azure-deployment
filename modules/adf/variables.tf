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
    "workload"                          = "Need to fill"
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

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa'"
  validation {
    condition     = var.environment == null ? true : contains(["prod", "dev", "qa", "sbx", "test"], var.environment)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}

variable "workload" {
  type        = string
  default     = null
  description = "Default prefix of the resource group name that will be created."
}
variable "project" {
  type        = string
  default     = null
  description = "Default prefix of the resource group name that will be created."
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
  type    = string
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
variable "app_env" {
  type = string
}

# variable "env" {
#   type        = string
#   description = "Environment name"
# }

variable "custom_adf_name" {
  type        = string
  description = "Specifies the name of the Data Factory"
  default     = null
}

variable "custom_default_ir_name" {
  type        = string
  description = "Specifies the name of the Managed Integration Runtime"
  default     = null
}

variable "custom_diagnostics_name" {
  type        = string
  description = "Specifies the name of Diagnostic Settings that monitors ADF"
  default     = null
}

variable "custom_shir_name" {
  type        = string
  description = "Specifies the name of Self Hosted Integration runtime"
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "public_network_enabled" {
  type        = bool
  description = "Is the Data Factory visible to the public network?"
  default     = false
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Is Managed Virtual Network enabled?"
  default     = true
}

variable "cleanup_enabled" {
  type        = bool
  description = "Cluster will not be recycled and it will be used in next data flow activity run until TTL (time to live) is reached if this is set as false"
  default     = true
}

variable "compute_type" {
  type        = string
  description = "Compute type of the cluster which will execute data flow job: [General|ComputeOptimized|MemoryOptimized]"
  default     = "General"
}

variable "core_count" {
  type        = number
  description = "Core count of the cluster which will execute data flow job: [8|16|32|48|144|272]"
  default     = 8
}

variable "vsts_configuration" {
  type        = map(string)
  description = "Code storage configuration map"
  default     = {}
}

variable "permissions" {
  type        = list(map(string))
  description = "Data Factory permission map"
  default = [
    {
      object_id = null
      role      = null
    }
  ]
}

variable "time_to_live_min" {
  type        = string
  description = "TTL for Integration runtime"
  default     = 15
}

variable "virtual_network_enabled" {
  type        = bool
  description = "Managed Virtual Network for Integration runtime"
  default     = true
}

variable "self_hosted_integration_runtime_enabled" {
  type        = bool
  description = "Self Hosted Integration runtime"
  default     = false
}

# Log Analytics
variable "log_analytics_workspace" {
  type        = map(string)
  description = "Log Analytics Workspace Name to ID map"
  default     = {}
}

variable "analytics_destination_type" {
  type        = string
  default     = "Dedicated"
  description = "Log analytics destination type"
}

variable "managed_private_endpoint" {
  type = set(object({
    name               = string
    target_resource_id = string
    subresource_name   = string
  }))
  description = "The ID  and sub resource name of the Private Link Enabled Remote Resource which this Data Factory Private Endpoint should be connected to"
  default     = []
}

variable "global_parameter" {
  type = list(object({
    name  = string
    type  = optional(string, "String")
    value = string
  }))
  default     = []
  description = "Configuration of data factory global parameters"
}

variable "key_vault_name" {
  type = string
}

variable "resource_group" {
  type = string
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